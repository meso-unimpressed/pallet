# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

# log SQL queries into different log file (and not any more in standard log file)
ActiveRecord::Base.logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_database.log")


# not logging Session ID
class ActionController::Base
  def log_processing
    if logger
      logger.info "\n----------------------------------------------------------------------------------------------------"
      logger.info "\nProcessing #{controller_class_name}\##{action_name} (for #{request_origin}) [#{request.method.to_s.upcase}]"
      #logger.info "  Session ID: #{@_session.session_id}" if @_session and @_session.respond_to?(:session_id)
      logger.info "  Parameters: #{respond_to?(:filter_parameters) ? filter_parameters(params).inspect : params.inspect}"
    end
  end
end
