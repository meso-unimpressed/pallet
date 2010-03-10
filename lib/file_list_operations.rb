module FileListOperations
#  require "tempfile"
#  require "stringio"
  require "fileutils"

  def file_list_operation_delete(selected_files, selected_directories)
    flash[:notice] ||= ''
    file_count = 0
    dir_count = 0
    
    if selected_files
      selected_files.each do |name|
        logger.debug "\n===> deleteing file #{name}\n"
        delete(name, 'file', false)
        file_count += 1
      end
    end
    if selected_directories
      selected_directories.each do |name|
        logger.debug "\n===> deleteing directory #{name}\n"
        delete(name, 'directory', false)
        dir_count += 1
      end
    end
    
    if dir_count > 0
      content = t('flash.directory').pluralize_by(dir_count, :number => true, :plural => t('flash.directories'))
      flash[:notice] << t('flash.content_deleted', :content => content) << '<br />'
    end

    if file_count > 0
      content = t('flash.file').pluralize_by(file_count, :number => true, :plural => t('flash.files'))
      flash[:notice] << t('flash.content_deleted', :content => content) << '<br />'
    end
  end

  def collection_operation_delete
    collection = (session[@pallet.collection][:files] + session[@pallet.collection][:directories])
    success_count = 0
    collection.each do |element|
      logger.debug "\n===> deleteing #{element}\n"
      element_path = @pallet.path + '/' + element
      if file_type(element_path) != 'unknown'
        FileUtils.remove_dir element_path
        success_count += 1
      else
        flash[:error] << t('flash.could_not_be_deleted') if flash[:error].blank?
        flash[:error] << element << '<br/>'
      end
    end
    content = t('flash.element').pluralize_by(success_count, :number => true, :plural => t('flash.elements'))
    flash[:notice] << t('flash.content_deleted', :content => content) if success_count > 0
    collection_operation_clear
  end
  
  def collection_operation_collect(selected_files, selected_directories)
    #collection_operation_clear # todo: remove this
    flash[:notice] ||= ''
    flash[:error] ||= ''

    preset_collection_session
    
    # remember original collection size
    original_file_count = session[@pallet.collection][:files].size
    original_dir_count  = session[@pallet.collection][:directories].size
    
    # store collection
    selected_files.each { |file| session[@pallet.collection][:files] << relative_pallet_path_for(file) }
    selected_directories.each { |dir| session[@pallet.collection][:directories] << relative_pallet_path_for(dir) }
    
    # remove duplicates
    session[@pallet.collection][:files].uniq!
    session[@pallet.collection][:directories].uniq!
    
    # calculate changes
    new_file_count = session[@pallet.collection][:files].size
    new_dir_count  = session[@pallet.collection][:directories].size
    added_file_count = new_file_count - original_file_count
    added_dir_count  = new_dir_count  - original_dir_count    
    skipped_file_count = selected_files.to_a.size - added_file_count
    skipped_dir_count  = selected_directories.to_a.size - added_dir_count

    # remove redundant collected files and dirs
    redundant_file_count, redundant_dir_count = remove_collection_redundancy    
    
    # generate flash feedback
    if added_dir_count > 0
      flash[:notice] << t('flash.added_to_collection', 
                          :content => t('flash.directory').pluralize_by(added_dir_count, :number => true, :plural => t('flash.directories')))
    end
    if added_file_count > 0
      flash[:notice] << t('flash.added_to_collection', 
                          :content => t('flash.file').pluralize_by(added_file_count, :number => true, :plural => t('flash.files')))
    end

    if skipped_dir_count > 0
      flash[:error] << t('flash.already_collected',
                         :content => t('flash.directory').pluralize_by(skipped_dir_count, :number => true, :plural => t('flash.directories')))
    end
    if skipped_file_count > 0
      flash[:error] << t('flash.already_collected',
                         :content => t('flash.file').pluralize_by(skipped_file_count, :number => true, :plural => t('flash.files')))
    end
    
    if redundant_dir_count > 0
      flash[:error] << t('flash.covered_by_parent',
                         :content => t('flash.directory').pluralize_by(redundant_dir_count, :number => true, :plural => t('flash.directories')))
    end
    if redundant_file_count > 0
      flash[:error] << t('flash.covered_by_parent',
                         :content => t('flash.file').pluralize_by(redundant_file_count, :number => true, :plural => t('flash.files')))
    end

    #logger.debug "\n===> #{session[@pallet.collection][:directories].to_yaml}\n"
    #logger.debug "\n===> #{session[@pallet.collection][:files].to_yaml}\n"

    @collection_elements = get_collection_elements

    render :partial => 'collection'
  end
  
  def collection_operation_remove(selected_files, selected_directories)
    preset_collection_session
    selected_files.each { |file| session[@pallet.collection][:files].delete file }
    selected_directories.each { |dir| session[@pallet.collection][:directories].delete dir }
    
    flash[:notice] = t('flash.removed_from_collection', :content => t('flash.file').camelize)      unless selected_files.empty?
    flash[:notice] = t('flash.removed_from_collection', :content => t('flash.directory').camelize) unless selected_directories.empty?
  end
  
  def collection_operation_copy(options = {})
    options = { :remove_source => false }.merge options
    
    flash[:notice] ||= ''
    flash[:error] ||= ''

    selection = session[@pallet.collection][:directories] + session[@pallet.collection][:files]

    successful_operation_count = 0
    for element in selection
      old_path = @pallet.path + '/' + element
      new_path = @current_path + '/' + File.basename(element)

      unless File.exists? new_path or path_below_self?(old_path, new_path)
        logger.debug "\n===> pasting #{old_path} to #{new_path}\n"
        if File.exists? old_path 
          # Recursively copy the first directory into the second
          FileUtils.cp_r(old_path, new_path) if options[:remove_source] == false
          # moving works for files and directories
          File.rename(old_path, new_path)    if options[:remove_source] == true
          successful_operation_count += 1
        else
          source_not_found ||= t('flash.not_found_changed_during_operation')
          source_not_found << "#{element}<br/>"
        end
      else
        if File.exists? new_path
          flash[:error] << t('flash.exists_on_destination', :element => element)
        else
          copying_to_self = t('flash.copy_to_itself', :element => element)
        end
      end
    end
    
    flash[:error] << source_not_found if source_not_found
    flash[:error] << copying_to_self if copying_to_self
    
    if options[:remove_source]
      # reset collection
      collection_operation_clear
      flash[:notice] = t('flash.moved_successful', :count => successful_operation_count)
    else
      flash[:notice] = t('flash.copied_successful', :count => successful_operation_count)
    end
  end
  
  def collection_operation_zip
    collection, zip_temp_dir_path = sanitize_zip_collection_collisions
    
    zip_filename = sanitize_filename params[:zip_filename]
    zip_filename = (zip_filename + '.zip').gsub('.zip.zip', '.zip')
    zip_filepath = @current_path + '/' + zip_filename
    
    # ensure file does not exist, change filename otherwise
    while File.file? zip_filepath
      zip_filename.gsub! '.zip', ''
      zip_filepath = @current_path + '/' + zip_filename.succ + '.zip'
    end
    
    collection.each do |element|
      dirname, filename = File.split(element)
      logger.debug "\n===> #{dirname} - #{filename}\n"
      if file_type(element) != 'unknown'
        zip(dirname, [filename], zip_filepath, false)
      else
        flash[:error] << t('flash.element_not_found_skipped', :element => element)
      end
    end
    
    flash[:notice] = t('flash.zip_file_created')

    # remove 
    FileUtils.remove_dir zip_temp_dir_path

    # reset collection
    #collection_operation_clear # not resetting collection, user might want to delete collected files after zipping
  end
  
  def collection_operation_clear
    session[@pallet.collection] = nil
  end
  
  # create relative (user friendly) sub path for pallet
  # below current pallet root path, without leading slash
  def relative_pallet_path_for(element)    
    sub_path = @sub_path.to_s
    sub_path = sub_path[1..-1] + '/' unless sub_path.blank?
    return sub_path << element
  end
  
  def preset_collection_session
    session[@pallet.collection] ||= { :files => [], :directories => [] }
  end
  
  # copies files with identical filenames to temporary folder and adds hierarchy
  # as string to filename, to solve the conflicts
  # creates zip temp dir, which will be returned too, so it can be cleaned up
  # by caller after processing
  def sanitize_zip_collection_collisions
    collection = session[@pallet.collection][:files] + session[@pallet.collection][:directories]
    collisions = []
    processed = []
    collision_basenames = []
    
    # check all files for filename collisions
    session[@pallet.collection][:files].each do |c|
      basename = File.basename c
      unless processed.include? basename
        processed << basename
      else
        collection.delete c
        collisions << c
        collision_basenames << basename
      end
    end

    # move all missed (first occurance) collisions from collection to collision
    session[@pallet.collection][:files].each do |c|
      basename = File.basename c
      if collision_basenames.include? basename
        collection.delete c
        collisions << c
      end
    end
    collisions.uniq!
    
    # set absoulut path for collection elements
    collection.collect! do |c|
      dirname, filename = File.split(c)
      dirname = dirname == '.' ? @pallet.path : (@pallet.path + '/' + dirname)
      dirname + '/' + filename
    end
    
    logger.debug "\n\n===> #{collection.to_yaml}\n"
    logger.debug "\n===> #{collisions.to_yaml}\n\n"
    
    # create temporary zip folder for renamed elements
    zip_temp_dir_path = 'tmp/zip' + '/' + sanitize_filename(@pallet.name) + Time.now.to_i.to_s
    Dir.mkdir('tmp/zip') unless File.exists? 'tmp/zip'
    Dir.mkdir(zip_temp_dir_path) unless File.exists? zip_temp_dir_path
    
    unless collisions.empty?
      flash[:error] << t('flash.file_name_collisions', 
                         :collisions => t('flash.collision').pluralize_by(collisions.size, :number => true, :plural => t('flash.collisions')),
                         :count => collisions.size)
    end
    
    
    # rename/move collisioned elements and add new path to collection
    collisions.each do |c|
      original_name = c
      original_path = @pallet.path + '/' + original_name
      new_name = c.gsub('/', '_')
      temp_path = zip_temp_dir_path + '/' + new_name
      if original_name != new_name
        flash[:error] << t('flash.renamed_from_to', :from => original_name, :to => new_name)
      else
        flash[:error] << t('flash.element_not_renamed', :name)
      end
      FileUtils.cp_r(original_path, temp_path)
      collection << temp_path
    end
    return collection, zip_temp_dir_path
  end



private



  # remove files / dirs from collection, which are located below a collected dir
  def remove_collection_redundancy
    redundant_file_count = 0
    redundant_dir_count = 0
    redundant_files = []
    redundant_dirs = []

    session[@pallet.collection][:directories].each do |dir|
      session[@pallet.collection][:files].each do |file|
        if file.starts_with?(dir + '/')
          logger.debug "\n===> removing redundancy for file: #{file}\n\n"
          redundant_file_count += 1
          redundant_files << file
        end
      end
      # find redundant dirs
      session[@pallet.collection][:directories].each do |t_dir|
        if t_dir.starts_with?(dir + '/')
          logger.debug "\n===> removing redundancy for dir: #{t_dir}\n\n"
          redundant_dir_count += 1
          redundant_dirs << t_dir
        end
      end
    end

    # actually remove redundancy
    redundant_files.each { |file| session[@pallet.collection][:files].delete file }
    redundant_dirs.each  { |dir|  session[@pallet.collection][:directories].delete dir }

    return redundant_file_count, redundant_dir_count
  end

  def get_collection_elements
    return [] unless session[@pallet.collection]

    collection_elements = []

    session[@pallet.collection][:directories].sort.each do |element|
      collection_elements << { :type => 'directory',
                               :path => element }
    end

    session[@pallet.collection][:files].sort.each do |element|
      collection_elements << { :type => 'files',
                               :extension => split_to_filename_and_extension(element).last,
                               :path => element }
    end
    return collection_elements
  end
  
end  
