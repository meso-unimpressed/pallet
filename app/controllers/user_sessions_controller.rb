class UserSessionsController < ApplicationController
  layout 'common'

  protect_from_forgery :except => [:create] # allow login with forgery unprotected session, to allow foreign login forms

  def new
    @user_session = UserSession.new
  end


  def create
    # if already logged in, automatically logout first
    @user_session = UserSession.find
    @user_session.destroy unless @user_session.nil?

    # issue a new session id and declare the old one invalid
    # (preventing session hijacking). restore session variables, though.
    session_backup = session.to_hash
    reset_session
    session_backup.each do |key, value|
      # do not restore pallet collections
      session[key] = value unless key.to_s.include? '_collection'
    end

    login = params[:user_session][:login]
    password = params[:user_session][:password]

    # try to find user. if not found, try to find+create by ldap (if enabled)
    # 
    user = User.find_by_login_or_create_from_ldap(login, password)

    # if user was not found and login was i.e. foo@bar.com try again with foo only
    if not user and login.include? '@'
      Rails.logger.info "\n===> login contains '@', trying login with leading part only\n"
      try_login = login.split('@').first
      login = try_login if user = User.find_by_login_or_create_from_ldap(try_login, password)
    end
    
    if user
      @user_session = UserSession.new(:login => login, :password => password)
      login_success = @user_session.save
    else
      login_success = false
    end

    if login_success
      flash[:notice] = t('flash.login_successful')
      redirect_back_or_default(AUTH_CONFIG['redirect_after_login'] || root_url)
    else
      if @user_session and @user_session.being_brute_force_protected?
        flash[:error] = t('flash.brute_force_protected')
      else
        flash[:error] = t('flash.wrong_login_data')
      end
      redirect_to login_path
    end
  end
  
  
  def destroy
    @user_session = UserSession.find
    @user_session.destroy unless @user_session.nil?
    session[:oca_token] = nil
    flash[:notice] = t('flash.logout_successful')
    redirect_to AUTH_CONFIG['redirect_after_logout'] || root_url
  end

end
