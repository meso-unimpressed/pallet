namespace :rails do 
  desc "Update the secret in the database.yml file"  
  task :update_secret => :environment do
    require 'yaml'

    yaml_path = 'config/database.yml'
    
    file_content = ''
    open(yaml_path, 'r') do |file|
      file.each { |line| file_content << line }
    end
    
    # TODO: use a better secret generation
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a 
    new_secret = Array.new(128, '').collect{chars[rand(chars.size)]}.join
    
    old_secret = 'will_be_replaced_by_rails_update_secret_task_during_bootstrap_if_not_replaced_manually'
    if file_content.index old_secret
      file_content.gsub!(old_secret, new_secret)      
    else
      puts "Secret was already changed, left untouched."
    end
    
    open(yaml_path, "w") do |file|
      file.puts(file_content)
    end
  end
end
