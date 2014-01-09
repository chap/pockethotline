module PagesHelper
	def percentage_of_minutes_remaining
		i = (minutes_remaining / 360.0 * 100).to_i
		i > 100 ? 100 : i
	end

  def minutes_remaining
    Sponsor.successful.minutes_remain.collect {|s| s.minutes_remaining }.sum
  end
end
