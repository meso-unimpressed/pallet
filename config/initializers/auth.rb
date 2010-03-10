
yaml_auth_config = YAML.load_file(File.join(Rails.root, "config", "auth.yml"))

# prevent nil exceptions if load fails
AUTH_CONFIG = { 'ldap' => {} }.merge(yaml_auth_config)

# create all non existing default roles
begin
  if AUTH_CONFIG['enable_ldap']
    default_role_titles = AUTH_CONFIG['ldap']['default_roles'].split(' ') rescue []
    default_role_titles.each do |role_title|
      unless Role.find_by_title role_title
        Role.create(:parent_id => 1,
                    :title => role_title,
                    :description => 'LDAP default role.')
      end
    end
  end
rescue
end