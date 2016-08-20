module UsersHelper

	def total_time_on_calls(user)
		if Call.where(operator_id: user.id).length > 1
			all_calls_for_user = Call.where(operator_id: user.id)
			total_time = 0
			all_calls_for_user.each do |call|
				total_time += call.length.to_i
			end
			total_minutes = total_time / 60 #rounded down to nearest minute.
			total_hours = (total_minutes / 60).to_s
			left_over_minutes = (total_minutes % 60).to_s
			if left_over_minutes.length == 1
				left_over_minutes = "0" + left_over_minutes[0] 
			end
			formated_time = total_hours + ":" + left_over_minutes 
			return formated_time
		else
			return 0
		end
	end

end

