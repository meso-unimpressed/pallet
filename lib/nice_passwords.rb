# Generates phonetical nice passwords
module NicePasswords
  def generate_nice_password(length = 8)
    #consonants = %w{ b c d f g h j k l m n p q r s t v w x y z }
    consonants = %w{ b c d f g h j k l m n p   r s t v w x   z }
    vocals = %w{ a e i o u }
    password = ''
    
    # decide first letter to be vocal or consonant
    current = rand(2) == 0 ? 'vocal' : 'consonant'  
    
    # at least one vocal and one consonant two times in password
    while password.empty? or
          unique_letters?(password, 1) or
          unique_consonants?(password, 0) or
          not unique_consonants?(password, 2) or
          not unique_letters?(password, 2)

      password = ''
      length.times do
  	
      if current == 'vocal'
    	  letter = vocals[rand(vocals.size)]
  	    current = 'consonant'
  	  else
        letter = consonants[rand(consonants.size)]
  	    current = 'vocal'
  	  end
        password << letter
      end
    end
    
    return password
  end

  def unique_consonants?(string, tolerance = 0)
    vocals = %w{ a e i o u }
    stripped_string = string
    vocals.each { |v| 
      stripped_string = stripped_string.gsub(v, '')
    }
    stripped_string.size - stripped_string.split(//).uniq.to_s.size <= tolerance
  end

  def unique_letters?(string, tolerance = 0)
    string.size - string.split(//).uniq.to_s.size <= tolerance
  end
end