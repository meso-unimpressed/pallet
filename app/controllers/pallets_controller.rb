class PalletsController < ApplicationController
  # actions
  include FileDirectoryHandling
  include OneClickAccess
  include UserRoleManagement
  
  # methods
  include FileOperations
  include FileListOperations
  include FileEncryption
  include NicePasswords
  include AdvancedStrings
  include OsDetect



  protect_from_forgery :except => [:upload] # TODO: should not be needed, but is. Autho Token is submitted correct.

  before_filter :login_by_session_data, :only => :upload
  before_filter :access_required
  before_filter :write_access_required, :only => [:upload, :upload_check, :create_dir, :collection_operation, :delete, :rename]

  helper_method :one_click_access_generation_allowed? # defined in module OneClickAccess 

  layout 'common'
  
  
  
  def index
    @pallets = accessible_pallets
    
    unless @pallets.blank?
      recently_accessed_pallet = SessionLog.recently_accessed_pallet(current_user_id)
      if @pallets.include? recently_accessed_pallet
        pallet_id = recently_accessed_pallet
      else
        pallet_id = @pallets.first
      end
      redirect_to :action => 'show', :id => pallet_id
    else      
      if current_user_has_role? 'admin'
        redirect_to :controller => 'pallet_global_configs'
      else
        flash[:error] = t('flash.no_accessible_pallet')
        redirect_to :controller => 'user_sessions', :action => 'new'
      end
    end
  end

  def show(options = {})
    get_current_path
    return if goto_root_on_invalid_path @current_path
    
    @pallet = Pallet.find_by_id(session[:pallet_id]) if session[:pallet_id]
    SessionLog.update_pallet_id(current_user_id, @pallet.id) if logged_in?
    set_sort_criteria
    @dir_list = retrieve_dir_list(@current_path)
    @collection_elements = get_collection_elements
  end

  def new
    @pallet = Pallet.new
  end

  def edit
    @pallet = Pallet.find(params[:id])
  end

  def create
    @pallet = Pallet.new(params[:pallet])
    @pallet.user = current_user

    respond_to do |format|
      if @pallet.save
        flash[:notice] = t('flash.pallet_created_successfully')
        associate_users
        # add pallet creator user to pallets user list
        Role.find_by_title(@pallet.standard_role_name).users << current_user
        format.html { redirect_to(@pallet) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @pallet = Pallet.find(params[:id])

    if @pallet.update_attributes(params[:pallet])
      flash[:notice] = t('flash.pallet_updated_successfully')
      #redirect_to(pallets_url)
      redirect_to(pallets_url)
    else
      render :action => "edit"
    end
  end

  def destroy
    @pallet = Pallet.find(params[:id])
    @pallet.destroy
    flash[:notice] = t('flash.pallet_deleted_successfully')
    redirect_to(pallets_url)
  end

  def auto_complete_for_user_association
    query = '%' + params[:q].downcase + '%'
    limit = (params[:limit].to_i/2).round
    items = []
    ['name', 'email'].each do |col|
      items += User.find(:all, :conditions => [ "LOWER(#{col}) LIKE ?", query]).collect(&col.to_sym).sort[0, limit]
    end
    render :text => items.join("\n")
  end

  def oca_tooltip
    get_current_path
    return if goto_root_on_invalid_path @current_path

    @pallet = Pallet.find_by_id(session[:pallet_id]) if session[:pallet_id]
    render :partial => 'one_click_access_list'
  end
  
  

protected



  def set_sub_path_from_params
    @sub_path = remove_relative_paths(params[:sub_path])
    @sub_path = nil if (@sub_path.nil? or @sub_path[0..0] != '/')
  end


  # redirects to action list, to list root, if path is invalid
  # type may be set to 'directory', to check if a path is a dir
  # type may be set to 'file', to check if a path is a file
  # type may be set to 'any', to check if a path is a dir OR a file
  def goto_root_on_invalid_path(path, type = 'directory')
    path = path.to_s
    if (not File.directory?(path) and type == 'directory') or
       (not File.file?(path) and type == 'file') or
       (not File.exists?(path))
      flash[:error] = t('flash.invalid_cannot_open')
      respond_to do |format|
        format.html { return redirect_to(:action => 'index') }
        format.js   { return render(:action => 'update_errors') }
      end
    end
    return false
  end
  
  # redirects to action list, if the given variable is not set
  # returns true if redirecting, false otherwise
  def goto_root_if_not_set(var)
    return redirect_to(:action => 'show') unless var
    return false
  end  
  
 
  # returns the actual path, constructed by root and sub path
  # access rights to workgroup are verified (unless false is passed)
  # strings, which may be used to try to move up in the hierachy are removed
  def get_current_path
    pallet_id = params[:id] || session[:pallet_id]
    session[:pallet_id] = pallet_id

    pallet = Pallet.find_by_id(pallet_id) if pallet_id
    
    #return if not @logged_in_by_session_data and not has_access_to? pallet
    return unless has_access_to? pallet

    set_sub_path_from_params

    params[:oca_sub_path] = nil if params[:oca_sub_path] == 'null'
    oca_sub_path = remove_relative_paths(params[:oca_sub_path] || session[:oca_sub_path].to_s)
    #logger.debug "\n||||| oca sub path: #{oca_sub_path}\n\n"

    @current_path = PalletGlobalConfig::root_path
    @current_path << pallet.directory + oca_sub_path
    @current_path << @sub_path.to_s
    #logger.debug "\n///// get_current_path returns: #{@current_path}\n"
  end
  
  # verifies access to specified workgroup by user account or access tokens
  def has_access_to? pallet
    return false unless pallet
    has_access = false

    if logged_in? and current_user and current_user != 'false'.to_sym
      # test for each role of user if it allows to access this workgroup
      #logger.debug "\n\\\\\\\\\\ has_access_to? returns #{(accessible_pallets.include? pallet)} (logged in user)\n\n"
      return true if accessible_pallets.include? pallet
      
    elsif session[:oca_token]
      # test for existing and unexpired token and if it points to this workgroup
      logger.debug "\n||||| #{session[:oca_token]}\n"
      one_click_access = PalletOneClickAccess.find_by_token(session[:oca_token])
      oca_pallet = Pallet.find(one_click_access.pallet_id)
      has_access = true if pallet == oca_pallet and not one_click_access.expired?
    end

    #logger.debug "\n\\\\\\\\\\ has_access_to? returns #{has_access} (NOT logged in user)\n\n"
    return has_access ? true : false
  end  
  
  # authenticate by user session_data param, login or by oca_token
  def access_required
    access_granted = false

    if logged_in?# or @logged_in_by_session_data
      #logger.debug "\n>> >> >> >> > Access granted by user: #{logged_in? ? current_user.login : @logged_in_by_session_data.login}\n"
      session[:oca_sub_path] = nil
      access_granted = true
    end

    oca_token = params[:oca_token] || session[:oca_token]
    if oca_token
      one_click_access = PalletOneClickAccess.find_by_token(oca_token)
      pallet = Pallet.find_by_oca_token oca_token
      if pallet
        #logger.debug "\n>> >> >> >> > Access granted by POCA token: #{one_click_access.token}\n"
        unless one_click_access.download.blank? # restricted to single file -> direct download
          file_path = File.join(PalletGlobalConfig::root_path, pallet.directory, one_click_access.sub_path, one_click_access.download)
          #logger.info "\n===> oca with download: #{file_path}\n"
          download_file file_path
        end

        unless session[:oca_token] == oca_token
          SessionLog.new(:oca_token           => oca_token,
                         :pallet_id           => pallet.id,
                         :oca_creator_user_id => one_click_access.user.id,
                         :logged_in_at        => Time.now).save
        end
          
        session[:oca_token] = oca_token
        session[:oca_sub_path] = one_click_access.sub_path
        session[:pallet_id] = pallet.id
        access_granted = true
      end

      unless access_granted
        if one_click_access and one_click_access.expired?
          flash[:error] = t('flash.oca_token_expired')
          logger.debug "\n===> token expired\n"
        else
          flash[:error] = t('flash.oca_token_unknown')
          logger.debug "\n===> token unknown\n"
        end
      end
    end
  
    return true if access_granted

    respond_to do |format|
      format.html { redirect_to login_url }
      #format.js   { render :action => 'update_errors' }
    end

    false
  end
  
  def write_access_required
    #logger.debug "\n====write_access_required======= \n"
    get_current_path
    #logger.debug "\n================================ \n"
    return if goto_root_on_invalid_path @current_path

    pallet = Pallet.find(session[:pallet_id]) if session[:pallet_id]

    if pallet.is_readonly and not (current_user_has_role? 'admin')
      logger.error "\n\n===> Tried write operation on read only pallet. Rejected.\n\n"
      flash[:error] = t('flash.pallet_no_write_access')
      respond_to do |format|
        format.html { redirect_to :controller => 'account', :action => 'login' }
        format.js   { render :action => 'update_errors' }
      end
      return false
    end
    
    return true
  end
  
  def login_by_session_data
    if not logged_in? and params[:action] == 'upload' and params[:session_data]
      data, digest = CGI.unescape(params[:session_data]).split('--')
      session_content = Marshal.load(Base64.decode64(data))

      #logger.debug "\n===> #{session_content.to_yaml}\n"

      # try to find a user by stored user id
      session_user = User.find_by_id(session_content["user_credentials_id"])
      
      # if valid user was found and not tampered with session param
      if session_user and generate_digest(data) == digest
        @current_user = session_user # log in user
        #@logged_in_by_session_data = session_user
        #logger.debug "\n\n\n>> >> >> >> > User logged in by session data param\n\n\n"
        return true
      end
    end
    return false
  end
  
  # Generate the HMAC keyed message digest. Uses SHA1 by default.
  # stolen, but modified from http://dev.rubyonrails.org/browser/trunk/actionpack/lib/action_controller/session/cookie_store.rb
  # TODO: use the method from class CGI::Session::CookieStore instead of duplicating it
  def generate_digest(data)
    db = YAML.load_file('config/database.yml')
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('SHA1'), db[RAILS_ENV]['secret'], data)
  end  
end
