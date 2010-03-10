module OsDetect
  def self.included(base)
    if base.respond_to?(:helper_method)
      base.send :helper_method, :detect_os, :client_os?
    end
  end

  # detects operating system
  # returns detected operating system (as symbol)
  # returns :unknown if operating could not be detected
  #
  # BE AWARE: only working for windows and macs. TODO: extend for solaris and linux
  #
  def detect_os(compare_os = nil)
    return case request.user_agent.downcase
      when /windows/i
        :windows
      when /macintosh/i
        :mac
      else
        :unknown
    end
  end

  # returns true if client operating system is given system
  #
  # BE AWARE: only working for windows and macs. TODO: extend for solaris and linux
  #
  def client_os? system
    detect_os == system.to_sym
  end
end
