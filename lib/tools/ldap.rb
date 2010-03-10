# LDAP utilities
#
# manages authentication and requesting credentials.
# wrapper for Ruby::Net::LDAP (requires gem ruby-net-ldap)
#
# tested with ruby-net-ldap 0.0.4
#
# for docs see: http://net-ldap.rubyforge.org/rdoc/
#

module Tools
  module LDAP

  public

    LDAP_DEFAULTS = { 'host_ip' => "127.0.0.1", 'host_port' => 389,
                      'host_base_dn' => '', 'attribute_username' => 'uid',
                      'validate_additional_fields' => {},
                      'validate_additional_fields_not_set' => {},
                      'method' => :simple
                    }

    # returns true or false if user login could be bound via ldap and all validations succeed
    #
    def self.auth(login, pwd, ldap_params = {})
      require 'net/ldap'
      ldap_options = LDAP_DEFAULTS.merge(ldap_params)
      ldap = create_connection(login, pwd, ldap_options)
      return false unless ldap.bind

      creds = request_credentials(login, pwd, ldap_options)
      Rails.logger.info "\n===> user credentials #{creds ? 'valid' : 'invalid'}\n"
      return false unless creds

      return false unless validate_fields(creds, ldap_options['validate_additional_fields'], true)
      Rails.logger.info "\n===> validate_additional_fields succeeded\n"

      return false unless validate_fields(creds, ldap_options['validate_additional_fields_not_set'], false)
      Rails.logger.info "\n===> validate_additional_fields_not_set succeeded\n"

      # MESO specific code: needs generalisation
      auth_mail_attribute = AUTH_CONFIG['ldap']['attribute_mail'].downcase
      return false unless validate_in_distribution_list(ldap, ldap_options, creds.first[auth_mail_attribute].to_s)
      Rails.logger.info "\n===> validate_in_distribution_list succeeded\n"

      return true
    end


    def self.request_credentials(login, pwd, ldap_params = {})
      require 'net/ldap'
      ldap_options = LDAP_DEFAULTS.merge(ldap_params)

      Rails.logger.info "\n===> LDAP lookup\n"

      ldap = create_connection(login, pwd, ldap_params)

      begin
        creds = ldap.search(
                   :base => ldap_options['host_base_dn'],
                   :filter => Net::LDAP::Filter.eq(ldap_options['attribute_username'], login)
                 )
      rescue Exception => exception
        Rails.logger.error "\n===> LDAP error: #{exception}\n\n"
        return nil
      end

      Rails.logger.info "\n===> user not found\n\n" unless creds
      return creds
    end

  private

    def self.create_connection(login, pwd, ldap_params = {})
      require 'net/ldap'

      if login.blank? or pwd.blank?
        Rails.logger.info "\n===> no connection established, login or password is blank\n"
        return false
      end

      ldap_options = LDAP_DEFAULTS.merge(ldap_params)

      ldap = Net::LDAP.new(:base => ldap_options['host_base_dn'],
                           :host => ldap_options['host_ip'],
                           :port => ldap_options['host_port'],
                           :auth => { :method => ldap_options['method'],
                                      :username => "#{ldap_options['attribute_username']}=#{login},#{ldap_options['host_base_dn']}",
                                      :password => pwd
                                    }
                          )

      #Rails.logger.info "\n===> #{ldap_options.to_yaml}\n"
      return ldap
    end

    # tests if specific fields in user ldap credentials are set or not set.
    # params:
    #   creds: credential structure as returned by request_credentials
    #   fields: see config/auth.yml for descriptions. contains credential names and values to test for/against
    #   test_if_set: if this is true, values are tested to exist and match in credentials.
    #                if set to false, validation will fail if value is set and matches the value supplied in fields
    #
    def self.validate_fields(creds, fields, test_if_set)
      validations = fields
      if validations and not validations.empty?
        validations = [ validations ] unless validations.first.class == Array # ensure multidimensional array

        validations.each do |validation|
          option, value = validation.first, validation.last
          if test_if_set
            return false unless creds.first[option].first == value
          else
            return false if creds.first[option].first == value
          end
        end
      end

      return true
    end

    #
    # MESO specific code: needs generalisation
    # check if user is in the distribution list cargo.meso.net
    # Check is without recursion (nested distribution lists)
    #
    def self.validate_in_distribution_list(ldap, ldap_options, mail)
      begin
        creds = ldap.search( :base => ldap_options['host_base_dn'],
                             :filter => Net::LDAP::Filter.eq('uid', 'cargo')
                            )
        return creds.first['zimbraMailForwardingAddress'.downcase].include?(mail)
      rescue Exception => exception
        Rails.logger.error "\n===> #{exception}\n"
        return nil
      end
    end

 end
end

