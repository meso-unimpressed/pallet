module FileEncryption
  # inspired by http://snippets.dzone.com/posts/show/991
  
  require 'openssl'
  require 'digest/sha1'
  require 'base64'  
  
  BLOCK_SEPARATOR = "\n-----BLOCK SEPARATOR-----\n"
  
  def encrypt_file(source_path, password, dest_path = nil)
    return unless File.file? source_path
    dest_path ||= new_filename_keep_path(source_path, File.basename(source_path) + '.enc')
    data = read_file(source_path, true)
    
    return false if data.nil? or data.empty?
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.encrypt
    c.key = Digest::SHA1.hexdigest(password)
    c.iv  = iv = c.random_iv
    e = c.update(data)
    e << c.final
    
    encryption = Base64.encode64(e) + BLOCK_SEPARATOR + 
                 Base64.encode64(iv)
    
    File.open(dest_path, 'w') { |f| f.write(encryption) }
    return File.file?(dest_path)
  end
  
  def decrypt_file(source_path, password, dest_path = nil)
    return unless File.file? source_path
    dest_path ||= new_filename_keep_path(source_path, File.basename(source_path).gsub('.enc', ''))
    
    data, iv = File.read(source_path).split(BLOCK_SEPARATOR)
    data = Base64.decode64(data)
    iv   = Base64.decode64(iv)
  
    return false if data.nil? or data.empty?
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.decrypt
    c.key = Digest::SHA1.hexdigest(password)
    c.iv  = iv
    d = c.update(data)
    d << c.final rescue return false
  
    File.open(dest_path, 'wb') { |f| f.write(d) }
    return File.file?(dest_path)
  end
  
  def read_file(path, binary = false)
    return '' unless File.file? path
    binary ? mode = 'rb' : 'r'
    file_content = ''
    open(path, mode) do |file|
      file.each { |line| file_content << line }
    end
    file_content
  end
  
  def new_filename_keep_path(file_path, new_file_name)
    File.join(File.dirname(file_path), new_file_name)
  end
end