class SponsorMailer < ActionMailer::Base
  default from: Rails.configuration.x.hotline.organizer_email

  def receipt(sponsor)
    @sponsor = sponsor
    @account = sponsor.account

    mail to: @sponsor.email,
         subject: "Receipt for Hotline minutes"
  end
end
