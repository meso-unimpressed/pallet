module FileDirectoryHandling
  include TrafficLogger
  
  def dialog_upload
    @pallet = Pallet.find(params[:id])
    set_sub_path_from_params

    render :update do |page|
      page.replace_html 'upload', :partial => ((client_os?(:mac)) ? 'uploadify_for_macs' : 'uploadify')
    end
  end
  

  def upload
    @pallet = Pallet.find(params[:id])
    file = params[:Filedata]
    
    #logger.debug "\n===> #{params.to_yaml}\n"
    #logger.debug "\n===> #{params[:sub_path]}\n"
    #logger.debug "\n===> #{@current_path}\n"
    
    if not has_accepted_extension?(file, @pallet.file_types.split(' '))
      logger.debug "\n===> wrong file extension!\n"          
      error_message = t('flash.wrong_filetype')
      flash[:error] = error_message
    elsif file.nil?
      logger.debug "\n===> no file selected!\n"          
      error_message = t('flash.no_file_selected')
      flash[:error] = error_message
    else
      logger.info "\n===> upload #{File.basename(file.original_filename)}\n"
      
      if file_provided? file or file.is_a? ModPorter::UploadedFile
        destination = @current_path + '/' + sanitize_filename(File.basename(file.original_filename))
        unless File.exists? destination
          if file.is_a? Tempfile or file.is_a? ModPorter::UploadedFile # or file.is_a? ActionController::UploadedTempfile
            logger.info "\n===> processing tempfile\n"                if file.is_a? Tempfile
            logger.info "\n===> processing ModPorter uploaded file\n" if file.is_a? ModPorter::UploadedFile
            # tempfile (or ModPorter) should be copied instead of opened and rewritten (especially big ones)

            # moving will be faster but may be forbidden by tempfile access resctrictions, so fall back to copying
            begin
              FileUtils.mv(file.path, destination)
              logger.info "\n===> moving ...\n"
            rescue
              FileUtils.cp(file.path, destination)
              logger.info "\n===> moving failed, fallback: copying ...\n"
            end
          elsif file.is_a? StringIO# or file.is_a? ActionController::UploadedStringIO
            logger.info "\n===> processing io object\n"
            # StringIO objects cant be copied, they have to be read and written to filesystem
            File.open(destination, "wb") { |f| f.write(file.read) }
          end
          logger.debug "\n===> #{destination}: #{File.size(destination)} Bytes\n"
          if File.size(destination) > (PalletGlobalConfig.max_upload_file_size_byte)
            File.delete(destination)
            logger.debug "\n===> file too big!\n"          
            flash[:error] = t('flash.size_limit_exceeded')
          else
            flash[:notice] = t('flash.upload_successful')
            TRAFFIC_LOG.info "File Upload: Path: #{destination}, Bytes: #{File.size(destination)}, User: #{current_user ? current_user.login : session[:oca_token]}"
          end
        else
          logger.error "\n===> destination exists!\n"
          error_message = t('flash.destination_exists')
          flash[:error] = error_message
        end
      else
        logger.error "\n===> source not found!\n"
      end
    end

    if params[:non_swf_upload]
      return redirect_to(:action => 'show', :id => session[:pallet_id], :sub_path => @sub_path)
    else
      if error_message.nil?
        render :nothing => true
      else
        render :text => { :message => error_message }.to_json
      end
    end
  end

  # uploadify check if file exists, before file is uploaded.
  # returns json encoded hash of files already existing on the system.
  def upload_check
    result = {}
    params.each_pair do |key, value|
      unless ['action', 'controller', 'folder', 'authenticity_token', 'session_data',
              'sub_path', 'id', 'oca_token'].include? key
        destination = @current_path + '/' + sanitize_filename(value)
        #logger.debug "\n===> #{key} -> #{value}\n"
        #logger.debug "\n=> #{destination} - #{File.exist? destination}\n"
        result[key] = value if File.exist? destination 
      end
    end
    render :text => result.to_json
  end

  def create_dir
    # "rename" sub_path to expected param (frontend uses different field names 
    # for the same attribute cause different IDs are needed for each input field)
    params[:sub_path] = params[:sub_path_for_new_dir]
    
    dir_name = sanitize_filename(params[:dir_name])
    return if goto_root_if_not_set dir_name

    get_current_path
    return if goto_root_on_invalid_path @current_path

    new_dir_path = @current_path + '/' + dir_name

    unless File.exists? new_dir_path
      Dir.mkdir(new_dir_path)
      flash[:notice] = t('flash.directory_created', :name => dir_name)
    else
      flash[:error] = t('flash.directory_exists', :name => dir_name)
    end

    return redirect_to(:action => 'show', :id => session[:pallet_id], :sub_path => @sub_path) 
  end

  def collection_operation
    get_current_path
    return if goto_root_on_invalid_path @current_path
    
    @pallet = Pallet.find(session[:pallet_id]) if session[:pallet_id]

    selected_files       = ActiveSupport::JSON.decode(params[:selected_files].to_s)       || []
    selected_directories = ActiveSupport::JSON.decode(params[:selected_directories].to_s) || []

    #logger.debug "\n===> #{params[:selected_directories].to_yaml}\n"
    #logger.debug "\n===> #{params[:operation]}\n"

    case params[:operation]
      when 'collect'           : return collection_operation_collect(selected_files, selected_directories)
      when 'collect_remove'    : collection_operation_remove(selected_files, selected_directories)
      when 'delete'            : file_list_operation_delete(selected_files, selected_directories)
      when 'delete_collection' : collection_operation_delete
      when 'move'              : collection_operation_copy(:remove_source => true)
      when 'copy'              : collection_operation_copy
      when 'zip'               : collection_operation_zip
      when 'clear'             : collection_operation_clear
    end
    return redirect_to(:action => 'show', :id => session[:pallet_id], :sub_path => @sub_path)
  end

  def delete(name = nil, type = nil, do_render = true)
    name ||= params[:name]
    type ||= params[:type]
    return if goto_root_if_not_set name

    get_current_path
    return if goto_root_on_invalid_path @current_path

    del_path = @current_path + '/' + name

    if (type == 'file' and File.file?(del_path)) or
       (type == 'directory' and File.directory?(del_path))
      FileUtils.remove_dir del_path
    end
    
    if do_render
      flash[:notice] = t('flash.content_deleted', :content => t('flash.' + type))
      return redirect_to(:action => 'show', :id => session[:pallet_id], :sub_path => @sub_path) 
    end
    
  end

  def rename
    params[:sub_path] = params[:rename_sub_path]
    get_current_path
    return if goto_root_on_invalid_path @current_path

    old_path = @current_path + '/' + params[:rename_original_filename]
    new_path = @current_path + '/' + sanitize_filename(params[:rename_new_filename])

    if File.exists? old_path and not File.exists? new_path
      logger.debug "\n===> #{session.to_yaml}\n"
      if has_accepted_extension?(new_path, Pallet.find(session[:pallet_id]).file_types.split(' '))
        File.rename(old_path, new_path)
        flash[:notice] = t('flash.content_renamed')
      else
        flash[:error] = t('flash.content_rename_failed_wrong_ext')
      end
    else
      flash[:error] = t('flash.content_rename_failed')
    end
    
    return redirect_to(:action => 'show', :id => session[:pallet_id], :sub_path => @sub_path)
  end
  
  def download_file(file_path = nil)
    unless file_path
      get_current_path
      return if goto_root_on_invalid_path @current_path
      file_path = File.join(@current_path, remove_relative_paths(params[:filename]))
      return if goto_root_on_invalid_path(file_path, 'file')
    end

    logger.info "\n===> #{file_path}\n"
    logger.info "\n===> #{File.exist?(file_path)}\n"
    logger.info "\n===> #{File.size(file_path)}\n"
    TRAFFIC_LOG.info "File Download: Path: #{file_path}, Bytes: #{File.size(file_path)}, User: #{current_user ? current_user.login : session[:oca_token]}"
    #send_file_with_mime_type file_path
    if Settings.x_accel_redirect
      logger.info "\n===> x_accel_redirect\n"
      send_file_via_nginx_x_accel_redirect file_path, 'application/octet-stream'
    else
      logger.info "\n===> send_file\n"
      send_file File.expand_path(file_path),
                :disposition => 'inline',
                :type => 'application/octet-stream',
                :x_sendfile => Settings.x_sendfile
    end
  end

  def send_file_via_nginx_x_accel_redirect file_path, type
    #Set the X-Accel-Redirect header with the path relative to the location in nginx
    response.headers['X-Accel-Redirect'] = File.join("/", file_path)
    #Set the Content-Type header as nginx won't change it and Rails will send text/html
    response.headers['Content-Type'] = type
    #If you want to force download, set the Content-Disposition header (which nginx won't change)
    response.headers['Content-Disposition'] = "attachment; filename=#{File.basename(file_path)}"
    #Make sure we don't render anything
    render :nothing => true
  end

  def encrypt_single_file
    params[:sub_path] = params[:encrypt_sub_path]
    get_current_path
    return if goto_root_on_invalid_path @current_path
    
    file_path = File.join(@current_path, params[:encrypt_original_filename])

    unless params[:do_decrypt] == 'true'
      if encrypt_file(file_path, params[:password])
        File.delete(file_path)
        flash[:notice] = t('flash.encrypt_successful')
        flash[:error] = t('flash.remember_password')
      else
        flash[:error] = t('flash.encrypt_failed')
      end
    else
      if decrypt_file(file_path, params[:password])
        File.delete(file_path)
        flash[:notice] = t('flash.decrypt_successful')
      else
        flash[:error] = t('flash.decrypt_failed')
      end
    end

    return redirect_to(:action => 'show', :id => session[:pallet_id], :sub_path => @sub_path)
  end



protected



  # update session with sort criteria if corresponding params are set
  def set_sort_criteria
    # reset descending order if order_by was changed
    switched_order_criteria = true if params[:order_by] and params[:order_by] != session[:order_by]

    session[:order_by]   = params[:order_by]   if params[:order_by]
    session[:order_desc] = params[:order_desc] if params[:order_desc]
    session[:order_desc] = false if params[:order_desc] == 'false' or switched_order_criteria
    session[:order_by] = 'filename' if session[:order_by].blank?
  end
  
  # read directory, determine additional attributes, sort, return hash
  def retrieve_dir_list(current_path)
    # filter, sort and get file attributes
    dir_list = get_dir_list(current_path)
    dir_list = enrich_with_attributes(dir_list, current_path)
    dir_list = sort_dir_list(dir_list, current_path) unless dir_list.empty?
    return dir_list
  end
  
end
