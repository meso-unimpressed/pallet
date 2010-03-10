
# Load mail configuration if not in test environment
if RAILS_ENV != 'test'
  ActionMailer::Base.delivery_method = :smtp

  email_settings = YAML::load(File.open("#{RAILS_ROOT}/config/oca_mailer.yml"))
  ActionMailer::Base.smtp_settings = email_settings[RAILS_ENV] unless email_settings[RAILS_ENV].nil?
end

