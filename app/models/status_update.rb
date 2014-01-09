class StatusUpdate < ActiveRecord::Base
  belongs_to :user
  belongs_to :account

  def open?
    started_at.present? && ended_at.blank?
  end

  def closed?
    started_at.present? && ended_at.present?
  end

  def length
    (ended_at || Time.now) - started_at
  end
end
