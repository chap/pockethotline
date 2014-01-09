class Activity < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  has_many :comments, :order => 'created_at asc'

  validates_presence_of :body
  validates :body, :unique_in_the_last_five_seconds => true

  def notify(link)
    UserMailer.notify_admin_of_activity_post(self, link).deliver
  end
end
