desc 'Chowning logfiles'
task :chown_log => :environment do
  #
  # The bootstrapping process will create logfiles with root as owner
  # This task will lookup the owner of the logfiles directory and set the same owner for all contained logfiles
  #

  require 'etc'

  uid = File.stat(File.join(RAILS_ROOT, 'log')).uid
  group_name = Etc.getpwuid(uid).name rescue nil

  if group_name
    begin
      #puts "#{uid} -> #{group_name}"
  
      Dir[File.join(RAILS_ROOT, 'log', '*.log')].each do |file|
        File.chown uid, uid, file
      end
    rescue
      puts 'failed'
    end
  end
end
