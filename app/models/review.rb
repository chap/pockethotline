class Review < ActiveRecord::Base
	include ActionView::Helpers::TextHelper # pluralize and truncate
  belongs_to :call

  validates_presence_of :question

  def notify
    UserMailer.notify_admin_of_review(self).deliver
  end

  def tweet
    TwitterIntegration.post(tweet_message)
    update_attribute(:tweeted_at, Time.now)
  end

  def should_tweet?
    TwitterIntegration.present? &&
  	['smile', nil, ''].include?(happiness) &&
  	tweeted_at.blank?
  end

  private
  def tweet_message
  	caller_twitter = twitter.present?? "@#{twitter.gsub('@', '').strip}" : nil
  	operator_twitter = call.operator.twitter.present?? "@#{call.operator.twitter.gsub('@','').strip}" : nil
  	minutes = call.length / 60

  	if caller_twitter && operator_twitter
  		message = [
  			"Thanks #{operator_twitter} for answering #{caller_twitter}'s call about [question]",
  			"+#{operator_twitter} just spent #{pluralize(minutes, 'min')} helping #{caller_twitter}",
  			"Just hosted a chat between #{operator_twitter} and #{caller_twitter} about [question]",
  			"Glad we could introduce #{caller_twitter} and #{operator_twitter}"
  		].sample
  	elsif caller_twitter
  		message = [
  			"Thanks for your call #{caller_twitter}",
  			"We just answered #{caller_twitter}'s question about [question]",
  			"Hope we could give you some help #{caller_twitter}",
  			"[question] was just asked by #{caller_twitter}"
  		].sample
  	elsif operator_twitter
  		message = [
  			"[question] was just answered by #{operator_twitter}",
  			"Someone just asked [question] and #{operator_twitter} answered",
  			"You rock #{operator_twitter}, answering [question]",
  			"Thanks for volunteering #{operator_twitter}"
  		].sample
  	else
  		message = [
  			"We just got a call about [question]",
  			"If you have a question about [question] give us a call",
  			"Someone just asked [question]",
  			"We just answered a question about [question]",
  			"Curious about [question]"
  		].sample
  	end

  	remaining = 140 - message.length + 8 # length of '[question]' - ""
  	message = message.gsub('[question]', "\"#{truncate(question, :length => remaining)}\"")
  	message
  end
end
