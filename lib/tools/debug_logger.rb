# Logging utilities
# 
# If useful, extend this as a mixin so it can be included into any
# model class (or even, conditionally in dev mode (Rails.env == 'development'),
# extend ActiveRecord!) to dump additional information such as class name, line of code etc. 
# 

module Tools
  module DebugLogger

    DEBUG_LOG_DIR = File.join(Rails.root, 'log')


    def self.log message
      self.log_to 'development.log', message
    end  


    def self.log_big message
      self.log_to 'development.log', "\n======  DEBUG:  ======"
      self.log_to 'development.log', message
      self.log_to 'development.log', "======================\n"
    end  


    def self.log_exception exception 
      self.log "\n========  CATCHED EXCEPTION  ======"
      self.log "  message: " << exception.inspect
      self.log "  time: " << Time.now.to_s
      self.log "===================================\n"
    end


    def self.log_to file_name, message
      if Rails.env == 'development'
        logger = Logger.new(File.join(DEBUG_LOG_DIR, file_name))
        logger.level = Logger::DEBUG
        logger.debug message
        logger.close
      end
    end
    
 end
end
 