class OneClickAccessMailer < ActionMailer::Base
  def invitation(one_click_access, email_receiver)
    sender_address = one_click_access.user.email
    sender_address = PalletGlobalConfig.email_robot_address if sender_address.empty?

    @subject    = PalletGlobalConfig.domain + ' One-Click-Access'
    @body       = { :one_click_access => one_click_access }
    @recipients = email_receiver
    @from       = sender_address
    @sent_on    = Time.now
    @headers    = {}
    @template   = "invitation_#{one_click_access.language}"
  end
end
