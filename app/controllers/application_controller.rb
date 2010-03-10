# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :set_locale
  before_filter :export_i18n_messages

  after_filter :discard_flash_if_xhr

  helper :all # include all helpers, all the time
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'd20501aa2d5f8a9618d4dc2c100077a5'

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :password_confirmation
  
  helper_method :current_user_session, :current_user, :logged_in?, :current_user_id, :current_user_has_role?
                
  custom_formats = {
    :date_dashed_and_time => "%Y-%m-%d %H:%M:%S",
    :default => "%d/%m/%Y %H:%M",
    :date_time12 => "%d/%m/%Y %I:%M%p",
    :date_time24 => "%d/%m/%Y %H:%M",
    :date_german => "%m.%m.%Y, %H:%M",
    :time => "%H:%M:%S",
    :hours_minutes => "%H:%M",
    :hour_only => "%H",
    :minute_only => "%M"
  }
  ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(custom_formats)
  ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(custom_formats)
  
  # returns list of pallets a user is assigned to by role association
  # returns all pallets if user is admin
  helper_method :accessible_pallets
  def accessible_pallets(user = nil)    
    return [] unless user or logged_in? or session[:oca_token]
    # return one click access pallets preferred, but only if no user was explicitly given as parameter
    return [Pallet.find_by_oca_token(session[:oca_token])] if session[:oca_token] and not user
    user ||= current_user
    pallets = user.has_role?('admin') ? (Pallet.find(:all) || []) : user.pallets
  end
  
  helper_method :current_pallet
  def current_pallet
    pallet = @pallet || Pallet.find_by_id(session[:pallet_id]) || accessible_pallets.first
    return pallet if accessible_pallets.include? pallet
  end
  
  
  #
  # authlogic part
  #
  
  
  # example:
  #   class MyClass
  #     require_login :role => :admin, :only => [:create]
  #     ...
  #   end
  #
  # role is optional. :only and :except work as specified in before_filter
  # 
  # this is a wrapper to pass arguments to the before_filter via a custom code block
  # 
  def self.require_login(options = {})
    role = nil
    role = options[:role].to_s if options[:role]
        
    before_filter :except => options[:except], :only => options[:only] do |controller|
      controller.verify_login(role)
    end
  end
    
  def verify_login(role = nil)
    if current_user
      login_ok = role ? current_user.has_role?(role) : true
    end
    
    unless login_ok
      store_location
      if role
        flash[:notice] = t('flash.login_required_with_role', :role => role.camelize)
      else
        flash[:notice] = t('flash.login_required')
      end
      redirect_to login_url
      return false
    end
    
    return true
  end



private


  
  # alias for current_user
  def logged_in?
    current_user
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  def current_user_id
    return logged_in? ? current_user.id : nil
  end
  
  def current_user_has_role?(role)
    return logged_in? ? current_user.has_role?(role) : false
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # set localisation language
  # use parameter if set, use user model language if available, use en as fallback
  def set_locale(locale = nil)
    current_user_language = current_user ? current_user.language : nil
    tlc = locale || current_user_language # || 'en'
    #logger.debug "\n===> #{tlc}\n"
    I18n.locale = tlc
  end

  def export_i18n_messages
    SimplesIdeias::I18n.export! if RAILS_ENV == "development"
  end  

  def discard_flash_if_xhr
    flash.discard if request.xhr?
  end
end
