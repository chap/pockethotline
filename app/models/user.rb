class User < ActiveRecord::Base
  attr_accessor :password, :admin_creating_user, :admin_updating_user, :user_applying, :user_updating_themselves, :skip_password_validation
  attr_accessible :email, :password, :password_confirmation, :phone, :name, :admin_creating_user, :twitter, :bio, :newsletter_emails, :schedule_emails, :user_updating_themselves, :skip_password_validation, :admins_notified_of_first_availability_at, :deleted_at

  belongs_to :account
  has_many :calls, :foreign_key => 'operator_id', :order => 'answered_at desc'
  has_many :status_updates, :dependent => :destroy, :order => 'started_at asc'
  has_many :points, :dependent => :destroy, :order => 'created_at desc'
  has_many :reviews, :order => 'created_at desc', :foreign_key => 'operator_id'
  has_many :oncall_schedules, :order => 'wday desc'
  has_many :comments, :order => 'created_at desc'
  has_many :activities, :order => 'created_at desc'

  before_save :encrypt_password, :unless => :no_password_required
  before_create :set_token

  validates_confirmation_of :password, :unless => :no_password_required
  validates_presence_of :password, :unless => :no_password_required
  validates_presence_of :name
  validates_uniqueness_of :email, :scope => :deleted_at
  validates_uniqueness_of :phone, :scope => :deleted_at, :unless => Proc.new {|u| u.phone.blank? }
  validates :phone, :presence => true, :unless => Proc.new {|u| u.admin_creating_user || u.admin_updating_user }
  validates :email, :presence => true, :email_format => true

  scope :on_call, where(:on_call => true)
  scope :active, where(:deleted_at => nil).where(:pending_approval => false)
  scope :pending, where(:pending_approval => true).where(:deleted_at => nil)
  scope :have_logged_in, where('password_hash is not ?', nil)
  scope :have_not_logged_in, where(:password_hash => nil)
  scope :admin, where(:admin => true)
  scope :receive_newsletters, where(:newsletter_emails => true)
  scope :receive_volunteers_first_availability, where(:volunteers_first_availability_emails => true)
  scope :has_phone, where('phone is not ?', nil).where('phone != ?', "")

  def total_points
    reviews.select {|c| c.award_point_to_operator? }.length
  end

  def toggle_status(status=nil)
    case status
    when :on
      go_on_call
      logger.info "[User] User:#{params[:id]} on call now, #{Time.zone.now}"
    when :off
      go_off_call
      logger.info "[User] User:#{params[:id]} off call now, #{Time.zone.now}"
    else
      if on_call
        go_off_call
        logger.info "[User] User:#{params[:id]} off call now, #{Time.zone.now}"
      else
        go_on_call
        logger.info "[User] User:#{params[:id]} on call now, #{Time.zone.now}"
      end
    end
  end

  def notify_admins_of_volunteers_first_availability
    if on_call? && admins_notified_of_first_availability_at.blank?
      User.admin.active.receive_volunteers_first_availability.each do |admin|
       # UserMailer.notify_admin_of_volunteers_first_availability(self, admin).deliver
      end
      self.update_attributes!(:admins_notified_of_first_availability_at => Time.now, :skip_password_validation => true, :admin_creating_user => true)
    end
  end

  def go_on_call
    if status_updates.empty? || status_updates.last && status_updates.last.closed?
      status_updates.create(:started_at => Time.now, :account => account)
    end
    TwitterIntegration.delay({:run_at => 10.minutes.from_now}).tweet_that_operators_are_on_call if TwitterIntegration.active?
    delay({:run_at => 10.minutes.from_now}).notify_admins_of_volunteers_first_availability if admins_notified_of_first_availability_at.blank? && !self.admin?
    update_attribute(:on_call, true)
  end
  private :go_on_call

  def go_off_call
    on_call_span = status_updates.last
    if on_call_span && on_call_span.open?
      on_call_span.update_attributes(:ended_at => Time.now)
    end

    calls.where(:ended_at => nil).each do |open_call|
      open_call.ended_at = Time.now
      open_call.save
    end

    self.update_attribute(:on_call, false)
  end
  private :go_off_call

  def self.authenticate(email, password)
    user = User.active.find_by_email(email)
    begin # if user hasn't set their password yet, we'll get a BCrypt::Errors::InvalidHash error
      if user && BCrypt::Password.new(user.password_hash) == password
        user
      else
        nil
      end
    rescue BCrypt::Errors::InvalidHash
      nil
    end
  end

  def self.authenticate_from_cookie(id=nil, password_hash=nil)
    if id && password_hash
      User.active.find_by_id_and_password_hash(id, password_hash)
    else
      nil
    end
  end

  def deactivate
    self.update_attribute(:deleted_at, Time.now)
  end

  def self.available_to_take_calls(include_those_on_call=false)
    users = User.includes(:calls).active.on_call.has_phone
    users = users.reject {|u| u.on_a_call?} unless include_those_on_call
    users
  end

  def on_a_call?
    calls.any? && calls.first.open?
  end

  def hours_on_call(start,stop)
    c = status_updates.where('started_at >= ?', start).where('started_at <= ?', stop)
    c.inject(0) { |sum, p| sum + p.length } / 3600
  end

  def length_of_calls(start,stop)
    c = calls_between(start,stop)
    c.inject(0) { |sum, p| p.length ? sum + p.length : sum } / 60
  end

  def calls_between(start,stop)
    calls.where('started_at >= ?', start).where('started_at <= ?', stop)
  end

  def jsonify(to_json=false)
    result = {}
    %w(name twitter bio on_call? on_a_call?).each do |a|
      result[a.to_sym] = self.send(a)
    end
    if to_json
      {:user => result}.to_json
    else
      result
    end
  end

  def update_oncall_status_from_schedule(status=nil, end_time=nil)
    if on_call? && status == :off || !on_call? && status == :on
      toggle_status(status)
      UserMailer.status_changed_by_schedule(self, status, end_time).deliver if self.schedule_emails?
    end
  end

  def gravatar(size='512')
    # include MD5 gem, should be part of standard ruby install
    require 'digest/md5'

    # create the md5 hash
    hash = Digest::MD5.hexdigest(email.downcase)

    image_src = "http://www.gravatar.com/avatar/#{hash}?s=#{size}"
  end

  private
  def encrypt_password
    if password.present?
      self.password_hash = BCrypt::Password.create(password)
    end
  end

  def no_password_required
    admin_creating_user || user_applying || user_updating_themselves || skip_password_validation
  end

  def set_token
    self.token = BCrypt::Engine.generate_salt.parameterize
    while User.find_by_token(self.token)
      self.token = BCrypt::Engine.generate_salt.parameterize
    end
  end
end
