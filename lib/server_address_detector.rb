module ServerAddressDetector

  # Returns Server Address  i.e. http://localhost:3000 or https://sub.domain.net
  # Params:
  #   protocol: prepend http:// or https://
  #   subdomain: return prepended subdomain with domain
  #   port: append port
  #   omit_default_port: do not append default ports 80 (http) or 443 (https)
  def server_address(options = {})
    options = { :protocol          => true,
                :subdomain         => true,
                :port              => true,
                :omit_default_port => true
              }.merge options

    domain = ''

    # detect protocol and domain with subdomain
    domain << (request.ssl? ? 'https://' : 'http://') if options[:protocol]

    # detect domain with or without subdomain 
    domain << (options[:subdomain] ? request.host : request.domain)

    # append port if port is not a standard port
    if options[:port]
      domain << ":#{request.port}" unless (options[:omit_default_port] and [80, 443].include? request.port)
    end

    return domain
  end
  
end
