class Pallet < ActiveRecord::Base
  include FileOperations
  require 'versioned_dirname'

  has_and_belongs_to_many :roles
  has_many :pallet_one_click_accesses

  belongs_to :user

  validates_presence_of   :name
  validates_uniqueness_of :name

  order_by :fields => ['name', 'created_at']
  
  
  
  def before_create
    create_and_set_dirname
  end
  
  def before_save
    self.file_types = self.file_types.strip.gsub('  ', ' ').gsub('  ', ' ')
    sanitize_file_types
  end
  
  def after_create
    create_pallet_dir
    create_pallet_role
    add_auto_associated_roles
  end
  
  def after_destroy
    destroy_pallet_dir
    destroy_pallet_role
  end
  

  
  def self.find_by_oca_token(token)
    one_click_access = PalletOneClickAccess.find_by_token(token)
    return one_click_access.pallet if one_click_access and not one_click_access.expired?
  end

  def standard_role_name
    'plt_' + sanitize_filename(self.directory) + '_user'
  end
  
  def standard_role
    Role.find_by_title(self.standard_role_name) rescue nil
  end
  
  def standard_role_user_ids
    Role.find(self.standard_role.id).users.collect{|u| u.id} rescue []
  end

  def one_click_access_generation_by_users?
    self.one_click_access_generation_by_users
  end
  
  def path
    PalletGlobalConfig::root_path + self.directory
  end
  
  def collection
    (self.name + '_collection').to_sym
  end
  
  def file_types_filter_format
    return '*.*' if self.file_types.blank?
    return self.file_types.split(' ').collect{ |c| '*.' + c }.join('; ')
  end
  
  def file_types_description_format
    return 'all files' if self.file_types.blank? or self.file_types == '*.*'
    return self.file_types.split(' ').join(', ')
  end
  
  # returns one click accesses by expiration date sorted
  # removes expired accesses
  def one_click_access_list
    PalletOneClickAccess.delete_all(["expires_at < ?", Time.now])
    ocal = self.pallet_one_click_accesses
    #ocal.sort { |a,b| a.expires_at <=> b.expires_at }
    ocal.sort { |a,b| a.sub_path <=> b.sub_path }
  end



private



  def create_pallet_dir
    PalletGlobalConfig::create_root_path # ensure root dir exists
    #new_dir = PalletGlobalConfig::root_path + self.directory
    Dir.mkdir self.path unless File.directory? self.path
    File.chmod(0750, self.path)
  end
  
  def destroy_pallet_dir
    #del_path = PalletGlobalConfig::root_path + self.directory
    FileUtils.remove_dir self.path if File.directory?(self.path)
  end
  
  def create_pallet_role
    self.roles << Role.create!(:title => self.standard_role_name)
  end
  
  def destroy_pallet_role
    return unless(role = Role.find_by_title(self.standard_role_name))
    # TODO: use nullify instead?
    role.users.each { |u| role.users.delete u }
    role.destroy
  end
  
  def add_auto_associated_roles
    for role in PalletGlobalConfig::auto_associated_roles
      self.roles << role    
    end
  end
  
  def create_and_set_dirname
    dirpath = Dir.versioned_dirname(PalletGlobalConfig::root_path + sanitize_filename(self.name))
    dirname = dirpath.split('/').last
    self.directory = dirname    
  end
  
  def sanitize_file_types
    # remove special chars and duplicates
    self.file_types = self.file_types.gsub('*.*', '*')
    return if self.file_types.strip == '*'
    self.file_types = self.file_types.gsub(/[^a-zA-Z0-9\s]/, ' ').split(' ').uniq.join(' ')
  end

end
