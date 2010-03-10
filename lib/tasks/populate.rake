desc 'Populating Database'
task :populate => :environment do
  require 'active_record/fixtures'
  
  # only load fixtures if PalletGlobalConfig table is empty (no fixtures were loaded yet)
  if PalletGlobalConfig.find(:all).empty?
    # path to population fixtures
    sub_path = 'db/populate'
    
    # load default fixture list
    fixtures = Dir[RAILS_ROOT + '/' + sub_path + '/*.yml'].sort
    
    puts
    
    fixtures.each do |file|
      # relative path to fixtures (different for default and localized fixtures)
      fixture_path = File.dirname(File.join(sub_path, file.split(sub_path).last))
      
      # fixture filename
      base_name = File.basename(file, '.*')
      
      puts "#{base_name} ..."   
      
      # load fixture into db
      Fixtures.create_fixtures(fixture_path, base_name)
    end
  else
    puts "PalletGlobalConfig table not empty. Skipping."
  end  
end
