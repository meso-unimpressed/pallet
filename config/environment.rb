# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  config.gem "authlogic", :version => '2.0.13'
  config.gem "settingslogic", :version => '2.0.3'
  #config.gem "ruby-net-ldap", :version => '0.0.4' # optional - only needed when using LDAP
  config.gem 'mislav-will_paginate', 
    :lib => 'will_paginate', 
    :source => 'http://gems.github.com'


  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  require 'yaml'
  db = YAML.load_file('config/database.yml')
  config.action_controller.session = {
    :session_key => db[RAILS_ENV]['session_key'],
    :secret      => db[RAILS_ENV]['secret']
  }

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Internationalization default language
  config.i18n.default_locale = :en
  config.i18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', '**', '*.{rb,yml}')]

  # setting up logger for traffic logging
  class AuditLogger < Logger
    def format_message(severity, timestamp, progname, msg)
      "#{severity[0,1]}, [#{timestamp.to_formatted_s(:db)}]  #{severity} -- : #{msg}\n"
    end
  end

  logfile = File.new(File.join(RAILS_ROOT, 'log', 'traffic.log'), 'a')
  logfile.sync = true
  TRAFFIC_LOG = AuditLogger.new(logfile)
end
