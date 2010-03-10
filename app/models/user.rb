class User < ActiveRecord::Base

  has_many :roles_users
  has_many :roles, :through => :roles_users
  has_many :session_logs


  # =============================== 
  # ==  AUTHLOGIC CONFIGURATION  ==
  # =============================== 

  # authlogic configuration options
  acts_as_authentic do |configuration|
    configuration.logged_in_timeout = AUTH_CONFIG['login_timeout'].to_i.minutes

    # email field validation is not used since when no email in ldap info is found,
    # default email will throw duplicate email error in authlogic
    configuration.validate_email_field = false
  end


  # ============================ 
  # ==  APPLICATION SPECIFIC  ==
  # ============================ 
  
  # returns list of pallets a user is assigned to by role association
  def pallets
    user_pallets = []
    for role in self.roles
      for p in role.pallets
        user_pallets << p
      end
    end
    user_pallets.uniq
  end
  
  
  # ============================== 
  # ==  SESSION LOG MANAGEMENT  ==
  # ============================== 
  
  # returns the user's session log prior to the current one (only makes sense if logged in!)
  def previous_session_log
    session_logs = (self.session_logs.sort_by { |session_log| session_log.logged_in_at })
    session_logs.pop # discard the last session
    return session_logs.last 
  end
  
  
  # returns the current session log if logged in, or the last session when user was logged in
  def current_session_log
    return (self.session_logs.sort_by { |session_log| session_log.logged_in_at }).last
  end
  
  
  # ======================= 
  # ==  ROLE MANAGEMENT  ==
  # ======================= 

  # returns an array of role titles 
  def role_titles
    self.roles.collect { |role| role.title }
  end

  
  # role can be a role title (string/symbol) or a role object
  # NOTE: if the user has a role, the user also authentificates for all child roles
  def has_role? role
    role = Role.find_by_title(role.to_s) unless role.class == Role
    return false unless role
    
    self.roles.each do |user_role|
      return true if role == user_role or role.ancestors.include?(user_role)
    end
    
    return false
  end


  # roles can be names (strings or symbols) or Role objects
  def has_any_role? roles_list
    roles_list.each do |role|
      return true if self.has_role?(role)
    end
    
    return false
  end


  # accepts multiple objects or ids or arrays of both as params
  def add_roles *roles
    roles.flatten.compact.each do |role|
      role = Role.find_by_id(role) unless role.class == Role
      self.roles << role unless self.roles.include?(role)
    end
  end

  
  # accepts objects or ids or arrays of both
  def remove_roles *roles
    roles.flatten.compact.each do |role|
      role = Role.find_by_id(role) unless role.class == Role
      self.roles.delete(role)
    end
  end


  # ======================= 
  # ==  AUTH MANAGEMENT  ==
  # ======================= 
  
  # tries to find an existing user or to create him from ldap (if enabled)
  def self.find_by_login_or_create_from_ldap login, password_plaintext
    user = User.find_by_login(login)
    Rails.logger.info "\n===> user found in db: #{user.class == User} #{"-> ID: #{user.id}, login: #{user.login}" rescue nil}\n"

    # no user found? create from ldap if enabled
    if user.nil? and (AUTH_CONFIG['enable_ldap'].to_s == 'true') and (AUTH_CONFIG['ldap']['auto_import'].to_s == 'true')
      user = self.migrate_from_ldap(login, password_plaintext)
    end
    
    return user
  end
  


protected 



  # ======================= 
  # ==  AUTH MANAGEMENT  ==
  # ======================= 

  # authlogic hook
  # 
  def custom_validate_credentials? password_plaintext
    if self.ldap_auth and AUTH_CONFIG['ldap']
      return Tools::LDAP::auth(self.login, password_plaintext, AUTH_CONFIG['ldap']) 
    else
      # no ldap: call default authlogic validation
      return self.valid_password?(password_plaintext)
    end
  end
 

  # creates a new user by extracting user credentials from ldap
  # returns the user or nil if not successful
  def self.migrate_from_ldap login, password_plaintext
    user = User.new
    
    user.login = login
    user.password = password_plaintext
    user.password_confirmation = password_plaintext
    user.email = AUTH_CONFIG['ldap']['default_user_email']
    user.name = AUTH_CONFIG['ldap']['default_user_name']
    user.ldap_auth = true

    credentials = Tools::LDAP::request_credentials(login, password_plaintext, AUTH_CONFIG['ldap'])
    return nil unless credentials

    mail_attribute = AUTH_CONFIG['ldap']['attribute_mail'].downcase || 'mail' rescue 'mail'
    name_attribute = AUTH_CONFIG['ldap']['attribute_name'] || 'cn' rescue 'cn'

    credentials.first.each do |attribute, values|
      unless values.empty?
        case attribute.to_s
          when mail_attribute then user.email = values.first.to_s
          when name_attribute then user.name = values.first.to_s
        end
      end
    end
    
    user.language = I18n.default_locale.to_s
    
    return nil unless user.save
    
    # add default roles    
    default_role_titles = AUTH_CONFIG['ldap']['default_roles'].split(' ') rescue []
    
    default_roles = default_role_titles.map { |title| Role.find_by_title(title) }
    user.add_roles(default_roles)
    
    return user
  end
 
end
