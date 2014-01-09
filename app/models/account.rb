class Account < ActiveRecord::Base
  def assign_toll_free_number(start_url,finish_url)
    if Rails.env.production?
      # todo
      # account for twilio failure
      subaccount = TWILIO.accounts.create(:friendly_name => name)
      numbers = subaccount.available_phone_numbers.get('US').toll_free.list
      number_to_buy = numbers[0].phone_number
      twilio_number = subaccount.incoming_phone_numbers.create(
        :friendly_name => name,
        :phone_number => number_to_buy,
        :voice_url => start_url,
        :voice_method => 'POST',
        :status_callback => finish_url,
        :status_callback_method => 'POST',
        :voice_fallback_url => "http://www.pockethotlinefallback.com"
      )

      self.update_attributes(
        :hotline_number => number_to_buy.gsub('+1', ''),
        :twilio_subaccount_sid => subaccount.sid,
        :twilio_subaccount_token => subaccount.auth_token,
        :twilio_phone_number_sid => twilio_number.sid
      )
    else
      self.update_attributes(
        :hotline_number => '8888888888',
        :twilio_subaccount_sid => 'xxx',
        :twilio_subaccount_token => 'xxx',
        :twilio_phone_number_sid => 'xxx'
      )
    end
  end

  def calls_by_hour(start, stop)
    c = calls_between(start,stop)
    num = []
    [3, 6, 9, 12, 15, 18, 21, 24].each do |hour|
      start_at = hour - 1.5
      end_at   = hour + 1.5
      num << c.select {
        |call| started_at = "#{call.started_at.hour}.#{call.started_at.min / 60}".to_f
        if hour == 24
          started_at >= start_at || started_at < 1.5
        else
          started_at >= start_at && started_at <= end_at
        end
      }.length
    end
    num
  end

  def hours_on_call(start,stop)
    c = status_updates.where('started_at >= ?', start).where('started_at <= ?', stop)
    c.inject(0) { |sum, p| sum + p.length } / 3600
  end

  def length_of_calls(start,stop)
    c = calls_between(start,stop)
    c.inject(0) { |sum, p| p.length ? sum + p.length : sum } / 60
  end

  def users_on_call_between(start, stop)
    users.select {|u| u.hours_on_call(start,stop) > 0 }
  end

  def calls_between(start,stop)
    calls.where('started_at >= ?', start).where('started_at <= ?', stop)
  end
  protected :calls_between

  def assign_sponsors_to_unsponsored_calls
    calls.unsponsored.each do |call|
      call.assign_sponsors
    end
  end
end
