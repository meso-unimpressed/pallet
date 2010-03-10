class UserSession < Authlogic::Session::Base

  verify_password_method :custom_validate_credentials?
  
  after_save :open_session_log_entry
  before_destroy :close_session_log_entry
  
  # logout after inactivity, default is false. see User model for timeout setting
  logout_on_timeout true 
  
  # don't show separate errors for login/password wrong! (considered bad security practice)
  # WARNING: in debug version this could be problematic because of no feedback!
  generalize_credentials_error_messages false
  
    
  def open_session_log_entry
    user = self.user
    return if user.nil?
    log_entry = SessionLog.new(:logged_in_at => Time.now) 
    user.session_logs << log_entry
  end
  
  def close_session_log_entry
    user = self.user
    return if user.nil?
    log_entry = user.current_session_log
    return if log_entry.nil?
    log_entry.logged_out_at = Time.now
    log_entry.save
  end

end
