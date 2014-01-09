class UserMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  default :from  => "#{Rails.configuration.x.hotline.name} <#{Rails.configuration.x.hotline.organizer_email}>"

  def welcome(user)
    @user    = user

    File.open("#{Rails.root}/tmp/#{Rails.configuration.x.hotline.name}.vcf", 'w') {|f| f.write(vcard_string) }
    @vcard = attachments["#{Rails.configuration.x.hotline.name}.vcf"] = File.read("#{Rails.root}/tmp/#{Rails.configuration.x.hotline.name}.vcf")
    mail :to => "#{@user.name} <#{@user.email}>",
         :subject => "You're invited to the #{Rails.configuration.x.hotline.name}"
  end

  def forgot_password(user)
    @user    = user

    mail :to => "#{@user.name} <#{@user.email}>",
         :subject => "Forgotten Password"
  end

  def user_applied(user)
    @user    = user

    mail :to => User.admin.collect(&:email),
         :subject => "New applicant for the #{Rails.configuration.x.hotline.name}"
  end

  def status_changed_by_schedule(user, status, end_time)
    @user    = user
    @status  = status
    Time.zone = Rails.configuration.time_zone
    @end_time = end_time
    @hours_on_call = ((((@end_time - Time.zone.now) / 60).to_i + 1) / 60)

    mail :to => "#{@user.name} <#{@user.email}>",
         :subject => "You're now #{@status} call"
  end

  def new_comment(to, comment, link)
    @link = link
    @comment = comment
    @activity = @comment.activity

    mail :to => to,
         :subject => "New Comment: #{truncate(@activity.body)}"
  end

  def notify_admin_of_activity_post(activity, link)
    @link = link
    @activity = activity
    mail :to => User.admin.collect(&:email),
         :subject => "New Activity: #{truncate(@activity.body)}"
  end

  def notify_admin_of_caller_review(review)
    @review = review
    mail :to => User.admin.collect(&:email),
         :subject => "New Review From Caller: #{truncate(@review.question)}"
  end

  def notify_admin_of_volunteers_first_availability(user, admin)
    @user = user
    @end_time = OncallSchedule.end_time_for_user(@user)
    mail :to => User.admin.collect(&:email),
         :subject => "#{@user.name} is on-call for the first time"
  end

  def vard_string
    <<-eos.strip_heredoc
      BEGIN:VCARD
      VERSION:3.0
      PRODID:-//Apple Inc.//iOS 5.0//EN
      N:;;;;
      FN:#{Rails.configuration.x.hotline.name}
      ORG:#{Rails.configuration.x.hotline.name};
      TEL;type=CELL;type=VOICE;type=pref:#{Rails.configuration.x.hotline.number}
      item1.URL;type=pref:http://#{Rails.configuration.x.hotline.domain}
      item1.X-ABLabel:_$!<HomePage>!$_
      X-ABShowAs:COMPANY
      END:VCARD
    eos
  end
end
