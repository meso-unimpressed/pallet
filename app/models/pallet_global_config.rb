class PalletGlobalConfig < ActiveRecord::Base
  validates_numericality_of :max_upload_file_size
  
  def validate_on_update
    new_path_not_existing?
  end
  
  def before_save
    PalletGlobalConfig::create_root_path(self.root_path)

    self.domain = 'http://' << self.domain unless self.domain.blank? or
                                                  self.domain.include? 'http://' or
                                                  self.domain.include? 'https://'
  end
  
  
  
  # Creates dir if not existing and no older config was stored before (only 
  # after first migration and first access)
  # If previously another config was saved, the old directory will be moved
  # to new location
  def self.create_root_path(path = nil)
    # TODO: create dirs, which are pointing to a deep structure
    # (needs to create upper structure first)
    old_dir = PalletGlobalConfig::root_path
    new_dir = path || root_path
    unless File.directory? old_dir
      Dir.mkdir new_dir unless File.directory? new_dir
      File.chmod(0750, new_dir)
    else
      # TODO: check for permission (if some user has shell or explorer open,
      # showing this dir, renaming fails!)
      File.rename(old_dir, new_dir) unless File.directory? new_dir
    end
  end
  
  def self.root_path
    PalletGlobalConfig.first.root_path + '/' rescue ''
  end

  def self.domain(options = {})
    options = { :omit_protocol => true }.merge options
    domain = PalletGlobalConfig.first.domain rescue ''
    domain = domain.gsub('http://', '').gsub('https://', '') if options[:omit_protocol]
    return domain
  end

  def self.domain_ssl?
    PalletGlobalConfig.domain(:omit_protocol => false).include?('https://')
  end
  
  def self.email_robot_address
    PalletGlobalConfig.first.email_robot_address rescue ''
  end  
  
  def self.max_upload_file_size
    PalletGlobalConfig.first.max_upload_file_size rescue 100
  end
  
  def self.max_upload_file_size_byte
    size = PalletGlobalConfig.first.max_upload_file_size rescue 100
    return size * 1024 * 1024
  end
  
  # Make the list of auto associated role ids accessible from this global 
  # config model due the auto associated roles are part of the global config
  def self.auto_associated_role_ids
    PalletAutoAssociatedRole.find(:all).collect{ |r| r.role_id.to_i }
  end
  # Same as above for the roles instead of role ids
  def self.auto_associated_roles
    self.auto_associated_role_ids.collect{ |rid| Role.find(rid) }
  end

  def self.theme_path
    theme_path = File.join(RAILS_ROOT, 'public', 'theme')
  end

  def self.available_themes
    themes = Dir.entries(theme_path).sort
    themes = themes.delete_if{ |d| ['.', '..'].include? d or File.file? File.join(PalletGlobalConfig.theme_path, d) }
    themes.collect { |t| [theme_description(t)[:name], t] }
  end

  def self.theme_description(theme)
    default_info = { :name => theme }
    info_file = File.join(theme_path, theme, 'theme.info')

    if File.file? info_file
      require 'yaml_config'
      default_info = YamlConfig.load(info_file, :use_rails_config_path => false)
    end

    return default_info
  end

  def self.theme
    theme = PalletGlobalConfig.first.theme
    theme.blank? ? 'default' : theme
  end

  def self.available_locales
    I18n.available_locales.collect do |tlc|
      [I18n.t("languages.#{tlc}"), tlc.to_s]
    end
  end



protected



  def new_path_not_existing?  
    root_path_changed = (PalletGlobalConfig::root_path != self.root_path + '/')
    if root_path_changed and File.directory? self.root_path
      errors.add :root_path, "exists, cannot overwrite existing directories"
      return false
    end
    true
  end
end
