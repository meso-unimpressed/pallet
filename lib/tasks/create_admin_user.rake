desc 'Creating Admin User'
task :create_admin_user => :environment do
  if platform_windows?
    require 'Win32API'
    rake_cmd = "rake.bat" #very important because windows will break with just "rake"
  else
    rake_cmd = "rake"
  end

  # only create admin user if user table is empty
  if User.find(:all).empty?
    password = ''
    password_confirm = 'unconfirmed'
    puts
    username = ask('Username (admin): ', :default => 'admin', :min_length => 4 )  
    while password != password_confirm
      password = ask('Password (admin): ', :default => 'admin', :min_length => 4, :plain => false )  
      password_confirm = ask('Password Confirmation (admin): ', :default => 'admin', :min_length => 4, :plain => false )      
      puts "\nPassword does not match confirmation, please try again\n\n" if password != password_confirm
    end

    user = User.create(:login => username, :password => password, :password_confirmation => password)

    # make new user an admin user
    RolesUser.create(:user_id => user.id, :role_id => Role.find_by_title('admin'))
  else
    puts "Users table not empty. Skipping."
  end
end

def ask(question, options = {})
  options = { :default => '',
              :min_length => 4,
              :plain => true }.merge options

  print question
  input = get_input(options[:plain])
  
  input = options[:default] if input.blank?
  
  while input.size < options[:min_length]
    print "Invalid. Must be at least #{options[:min_length]} characters long.\nAgain please: "
    input = get_input(options[:plain])
    input = options[:default] if input.blank?
  end
  
  return input
end  

def get_input(plain = true)
  if plain
    input = $stdin.gets.chop
  else
    # stolen from http://www.rubywiki.de/CodeShellPasswortEingabe
    if platform_windows?
      getch = Win32API.new("msvcrt", "_getch", [], 'L')
      char_range=0x20..0x7F
      input = ''
      char = '*'
      
      loop do
        c = getch.Call
        case c
          when 0x0d
            break
          when char_range
            input << c.chr
            if char
              STDERR.print char
            end
          when 0x08
            if input.length != 0
              STDERR.print "\x8" # BS backspace
              STDERR.print " "
              STDERR.print "\x8"
              input.chop!
            else
              STDERR.print "\x7" # BEL
            end
          else
            STDERR.print "\x7" # BEL if not allowed char
        end
      end
      STDERR.print "\n"      
    else
      begin
        system "stty -echo"
        input = $stdin.gets.chomp
        print "\n"
      ensure
        system "stty echo"
      end
    
    end
  end
  return input
end

def platform_windows?
  RUBY_PLATFORM =~ /win32|mswin|i386-mingw32/
end
