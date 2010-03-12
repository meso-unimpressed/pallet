
# Load mail configuration if not in test environment
if RAILS_ENV != 'test'
  oca_mailer_config_file = "#{RAILS_ROOT}/config/oca_mailer.yml"
  if File.exist? oca_mailer_config_file
    unless email_settings[RAILS_ENV].nil?
      ActionMailer::Base.delivery_method = :smtp

      email_settings = YAML::load(File.open(oca_mailer_config_file))
      ActionMailer::Base.smtp_settings = email_settings[RAILS_ENV]
    end
  end
end

