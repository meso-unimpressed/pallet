#
# Easy Yaml file Loader.
#
# require 'yaml_config'
# CONFIG = YamlConfig.load('config.yml')

class YamlConfig
  require 'yaml'


  # Loads a YAML file.
  # Extends path to rails app config path, unless use_rails_config_path is set to false.
  # Converts string hash keys to symbol keys, unless convert_hash_keys_to_symbols is set to false.
  # Returns empty hash if yaml file does not exist.
  # Use :node_path => [:foo, :bar] to return only subtree :bar of subtree :foo
  def self.load(yaml_path, options = {})  
    options = { :use_rails_config_path => true,
                :convert_hash_keys_to_symbols => true,
                :node_path => []
              }.merge options

    yaml_path = File.join(Rails.root, 'config', yaml_path) if options[:use_rails_config_path]

    config = YAML.load_file(yaml_path) rescue {}
    
    config = convert_hash_keys_to_symbols(config) if options[:convert_hash_keys_to_symbols]
    
    # return only specified node (if path is specified)
    options[:node_path].each do |node|
      config = config[node] rescue nil
    end
    
    return config
  end

  
  def self.convert_hash_keys_to_symbols(hash)   
    hash.each_pair do |key, value|
      if key.class == String
        hash[key.to_sym] = value
        hash.delete key
        
        convert_hash_keys_to_symbols(value) if value.class == Hash # traverse recursive
      end
    end
    return hash
  end

end
