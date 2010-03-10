desc 'Setup Application'
task :bootstrap => :environment do
  if platform_windows?
    require 'Win32API'
    rake_cmd = "rake.bat" # windows will break with just "rake"
    system("cls")
  else
    rake_cmd = "rake"
    system("clear")
  end

  table = User.find(:first) rescue nil # try to load data, to know if the database exists

  puts "\n\nSETTING UP PALLET APPLICATION"
  puts "\nUsing #{RAILS_ENV.upcase} environment#{" (toggle with RAILS_ENV=production)" if RAILS_ENV == 'development'}.\n\n"

  tasks = []

  unless table
    tasks << [ 'Updating secrets in database.yml.',   'rails:update_secret' ]
    tasks << [ 'Creating database.',                  'db:create' ]
    tasks << [ 'Loading database schema.',            'db:schema:load' ]
    tasks << [ 'Loading fixtures.',                   'populate' ]
    tasks << [ 'Creating an administrator user.',     'create_admin_user' ]
    tasks << [ 'Chowning logfiles.',                  'chown_log' ]

    tasks << [ "Done.\n\n\nStart your web server (ruby script/server) and begin to share your files." ]
  else
    tasks << [ "Database exists.\n\n\nDelete the database and bootstrap again, if you really want to discard all data." ]
  end

  tasks.each do |task|
    puts "\n\n\n#{task[0]}\n\n"
    system("#{rake_cmd} #{task[1]}") unless task[1].blank?
  end
end


def platform_windows?
  RUBY_PLATFORM =~ /win32|mswin|i386-mingw32/
end
