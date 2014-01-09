class OncallSchedule < ActiveRecord::Base
  # day 1 == monday
  belongs_to :user
  belongs_to :account

  scope :active_users, where('users.deleted_at is null').includes(:user)

  def to_abbrev
    options = {
      0 => 'Midnight',
      1 => '1am',
      2 => '2am',
      3 => '3am',
      4 => '4am',
      5 => '5am',
      6 => '6am',
      7 => '7am',
      8 => '8am',
      9 => '9am',
      10 => '10am',
      11 => '11am',
      12 => '12 noon',
      13 => '1pm',
      14 => '2pm',
      15 => '3pm',
      16 => '4pm',
      17 => '5pm',
      18 => '6pm',
      19 => '7pm',
      20 => '8pm',
      21 => '9pm',
      22 => '10pm',
      23 => '11pm',
      24 => '11:59pm'
    }

    "#{options[start_time.to_i]} - #{options[end_time.to_i]}"
  end

  def self.hourly_on_offs
    Time.zone = Rails.configuration.time_zone
    now = Time.zone.now
    schedules = OncallSchedule.includes([:account, :user]).all
    active_schedules = schedules.select {|s| s.wday == now.to_date.cwday && (s.start_time.to_f == now.hour || s.end_time.to_f == now.hour) }
    # schedules ending at midnight need to be run too
    active_schedules += schedules.select {|s| (s.wday == now.to_date.cwday - 1 || s.wday == 7 && now.to_date.cwday == 1) && s.end_time.to_f == 24 && now.hour == 0 }
    active_schedules.each do |schedule|
      schedule.activate(now)
    end
  end

  def self.end_time_for_user(user)
    Time.zone = Rails.configuration.time_zone
    now = Time.zone.now
    s = user.oncall_schedules.where('wday = ?', now.to_date.cwday).where('start_time = ?', now.hour.to_s).limit(1).first
    if s
      Time.zone.parse("#{now.to_date} #{s.end_time}")
    else
      nil
    end
  end

  def activate(now)
    start_datetime = Time.zone.parse("#{now.to_date} #{start_time}")
    end_datetime = Time.zone.parse("#{now.to_date} #{end_time}")
    if start_time.to_f == now.hour
      logger.info "[OncallSchedule:#{self.id}] Taking User:#{user.id} on call now, #{Time.zone.now}"
      user.update_oncall_status_from_schedule(:on, end_datetime)
    else
      logger.info "[OncallSchedule:#{self.id}] Taking User:#{user.id} off call now, #{Time.zone.now}"
      user.update_oncall_status_from_schedule(:off, end_datetime)
    end
  end
end
