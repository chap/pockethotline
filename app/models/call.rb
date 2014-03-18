class Call < ActiveRecord::Base
  belongs_to :account
  belongs_to :caller
  belongs_to :operator, :class_name => 'User'
  has_one :caller_review
  has_and_belongs_to_many :sponsors
  has_many :outgoing_calls
  has_one :review

  before_create :set_token

  scope :answered,   where('answered_at is not ?', nil)
  scope :unanswered, where('answered_at is ?', nil)
  scope :unsponsored, joins('left outer join calls_sponsors on calls.id=calls_sponsors.call_id').where('calls_sponsors.sponsor_id is null')
  scope :sponsored, joins('left outer join calls_sponsors on calls.id=calls_sponsors.call_id').where('calls_sponsors.sponsor_id is not null')

  def answered?
    answered_at.present?
  end

  def unanswered?
    answered_at.blank?
  end

  def open?
    ended_at.blank?
  end

  def finished?
    recording_duration.present? || ended_at.present?
  end

  def timecode
    begin
      hours   = (length / 3600).round
      minutes = ((length - (hours * 3600)) / 60).round
      seconds = ((length - (hours * 3600) - (minutes * 60)))

      result  = ""
      result += "#{hours}:" if hours > 0
      result += "#{minutes}:"
      result += "#{"%02d" % seconds}"
      result
    rescue
      '?'
    end
  end

  def self.create_from_twilio_params(params)
    caller = Caller.find_or_create_by_phone(
      :state        => params[:CallerState],
      :from_state   => params[:FromState],
      :city         => params[:CallerCity],
      :from_city    => params[:FromCity],
      :zip          => params[:CallerZip],
      :from_zip     => params[:FromZip],
      :phone        => params[:Caller],
      :from_phone   => params[:From],
      :country      => params[:CallerCountry],
      :from_country => params[:FromCountry],
    )

    caller.calls.create(:twilio_id  => params[:CallSid], :started_at => Time.now)
  end

  def redirect_if_not_answered(url)
    begin
      TWILIO.calls.get(self.twilio_id).redirect_to(url) if self.unanswered?
    rescue => e
      logger.info "Call could not redirect_if_not_answered: #{self.inspect} ERROR: #{e}"
    end
  end

  def notify_operators_of_hangup(url)
    outgoing_calls.each do |outgoing_call|
      begin
        c = TWILIO.calls.get(outgoing_call.twilio_id)
        c.redirect_to(url) if c.status == 'in-progress'
      rescue => e
        logger.info "Call could not notify_operators_of_hangup: #{c.inspect} ERROR: #{e}"
      end
    end
  end

  def assign_sponsors
    available_sponsors = Sponsor.successful.minutes_remain.order(:created_at)
    minutes = (length / 60)

    while (minutes > 0 && available_sponsors.any?) do
      sponsor = available_sponsors.select {|s| s.minutes_remaining > 0 }.first
      if sponsor
        minutes = minutes - sponsor.minutes_remaining
        self.sponsors << sponsor
        sponsor.update_attribute(:minutes_remaining, (minutes > 0 ? 0 : minutes.abs))
      else
        available_sponsors =[]
      end
    end
  end

  def request_caller_review
    message = "Did you get some help from the hotline? Take 2 mins and say thanks: http://#{Rails.configuration.x.hotline.domain}/c/#{token}"

    if TWILIO.sms.messages.create(
        :from => Rails.configuration.x.hotline.sms_number,
        :to => caller.phone,
        :body => message
      )
      self.update_attribute(:sms_caller_for_review_at, Time.now)
    else
      false
    end
  end

  private
  def set_token
    self.token = rand(36**8).to_s(36)
    while Call.find_by_token(self.token)
      self.token = rand(36**8).to_s(36)
    end
  end
end
