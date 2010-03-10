module FileOperations
  require 'zip/zip'
  require 'zip/zipfilesystem'

  include AdvancedStrings
  
  def get_dir_list(path)
    dir_list = Dir.entries(path)
    filter_dir_list! dir_list    
    dir_list
  end

  # uses a simple or a given filter, to remove files or dirs from a given list
  def filter_dir_list!(dir_list, filter = nil)
    filter ||= [ /^(\.)+$/, # . and ..
                 /^\.(.)*/  # beginning with .
               ]
    dir_list.delete_if { |element| match_filter?(element, filter) }
  end

  # used by filter_dir_list!() to conditionally remove entries from the dirlist
  def match_filter?(element, filter)
#    logger.debug "\n===> filtering #{element}\n"
    is_matched = false
    filter.each do |f|
      is_matched = (element.index(f) != nil)
#      logger.debug "-> #{element + ' ~ ' + f.to_s + ' : ' + is_matched.to_s}\n"
      break if is_matched
    end
    is_matched
  end
  
  # sort alphabetically and move directories to top
  def sort_dir_list(dir_list, path)
    order_by ||= session[:order_by]
    order_by ||= 'filename'
    order_desc = session[:order_desc]
    
    if dir_list.first[order_by.to_sym].class == Fixnum
      dir_list.sort! { |a,b| a[order_by.to_sym] <=> b[order_by.to_sym] }
    else
      dir_list.sort! { |a,b| a[order_by.to_sym].to_s.downcase <=> b[order_by.to_sym].to_s.downcase }
    end

    dir_list.reverse! if order_desc
    
    # move folders to top
    new_list = []
    new_dir_list = []
    dir_list.each do |element|
      new_list << element if File.directory?(path + '/' + element[:original_name])
      new_dir_list << element if File.file?(path + '/' + element[:original_name])
    end
    new_list.sort! { |a,b| a[:filename].to_s.downcase <=> b[:filename].to_s.downcase }
    new_list.concat new_dir_list
  end
  
  # replace filenames inside an array by an hash with additional infos
  # like filename, extension, type, size
  def enrich_with_attributes(dir_list, path)
    rich_dir_list = []
    dir_list.each do |element|
      file_path = path + '/' + element
      filename, extension = split_to_filename_and_extension element
      file_size = File.size file_path
      file_time = File.stat(file_path).mtime
      rich_dir_list << { :original_name => element, 
                         :filename => filename,
                         :extension => extension,
                         :type => file_type(file_path),
                         :size => file_size,
                         :file_time => file_time,
                         :timestamp => file_time.to_i
                       }
    end
    rich_dir_list
  end
  
  # returns a string depending on what the file_path is pointing to
  # file / directory / unknown
  def file_type(file_path)
    return 'file'      if File.file? file_path
    return 'directory' if File.directory? file_path
    return 'unknown'
  end
  
  def file_provided?(file)
    [ActionController::UploadedStringIO, ActionController::UploadedTempfile, 
     StringIO, Tempfile].include?(file.class) and file.size.nonzero?
  end  
  
  # splits string at last dot, returns part before and after that 
  # position, without the dot itself
  def split_to_filename_and_extension path
    extension = File.extname(path).gsub('.', '')
    filename  = File.basename(path, '.' + extension)
    return filename, extension
  end
  
  def sanitize_filename(name)
    return unless name
    # force copying string not referencing to prevent manipulation of given parameter
    result = "#{name}"
    replacements = [ [' ', '_'], 
                     ['Ä', 'Ae'], ['Ö', 'Oe'], ['Ü', 'Ue'],
                     ['ä', 'ae'], ['ö', 'oe'], ['ü', 'ue'], ['ß', 'ss']]
    result.multi_gsub!(replacements)
    result.gsub!(/[^a-zA-Z0-9\_\.\-]/, '')
    result.multi_gsub!([ ['__', '_'], ['__', '_'] ])
    return result
  end

  # zips files and directories to a zip file
  # path_to_file is expected to be the path, where the files are stored
  # files_to_zip is expected to be an array of filenames
  # zip_filepath is the path and filename of the zip file to be created
  # unless force_new_file is set to false, existing zip files with same name 
  # are removed and not filled up with new content
  def zip(path_to_files, files_to_zip, zip_filepath, force_new_file = true)
    return unless files_to_zip
    # remove zip file, if existing already
    File.delete zip_filepath if force_new_file and File.file? zip_filepath

    directories = []

    # open or create the zip file
    Zip::ZipFile.open(zip_filepath, Zip::ZipFile::CREATE) do |zipfile|
      files_to_zip.each do |filename|
        file_path = path_to_files + '/' + filename
        logger.debug "\n===> adding '#{filename}' from '#{file_path}'"
        zipfile.add(filename, file_path)

        directories << { :path => path_to_files, :name => filename } if File.directory? file_path
      end
    end
    
    # recursively adding directories, skipped but remembered before
    directories.each do |dir|
      get_dir_list(dir[:path] + '/' + dir[:name]).each do |sub_element|
        sub_filename = dir[:name] + '/' + sub_element
        zip(dir[:path], [ sub_filename ], zip_filepath, false)
      end
    end
  
    # set read permissions on the file
    File.chmod(0644, zip_filepath)    
  end  

  # used for looking up if tried to copy folder to itself
  def path_below_self?(old_path, new_path)
    return (new_path.index(old_path) != nil)
  end

  def remove_relative_paths path
    return unless path
    path.multi_gsub!([ ['../', ''], ['..', ''], ['./', ''] ])
    return path
  end

  # sends files inline, so browser can display images or text files
  # instead of sending them
  def send_file_with_mime_type file_path
    # more MIME types: http://de.selfhtml.org/diverses/mimetypen.htm
    kind_of_plain_text = %w{ txt php js css rb yml log }
    kind_of_html = %w{ htm html shtml }

    case split_to_filename_and_extension(file_path).last.downcase
      when /jp(e*)g/           then type = 'image/jpeg'
      when 'gif'               then type = 'image/gif'
      when 'png'               then type = 'image/png'
      when 'bmp'               then type = 'image/bmp'
      when 'xml'               then type = 'text/xml'
      when 'pdf'               then type = 'application/pdf'
      when *kind_of_plain_text then type = 'text/plain'
      when *kind_of_html       then type = 'text/html'
      else type = 'application/octet-stream'
    end

    if Settings.x_accel_redirect
      send_file_via_nginx_x_accel_redirect file_path, type
    else
      send_file File.expand_path(file_path), :disposition => 'inline', :type => type, :x_sendfile => Settings.x_sendfile
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



  def has_accepted_extension?(file, acceptable_types)
    return true if acceptable_types.blank? or acceptable_types.first == '*'
    filename = file.is_a?(String) ? file : file.original_filename
    extension = split_to_filename_and_extension(filename).last
    return true if acceptable_types.include? extension
    return false
  end

end
