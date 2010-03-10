module TrafficLogger
  # setting up logger for traffic logging
  class AuditLogger < Logger
    def format_message(severity, timestamp, progname, msg)
      "#{severity[0,1]}, [#{timestamp.to_formatted_s(:db)}]  #{severity} -- : #{msg}\n"
    end
  end

  logfile = File.open(File.join(RAILS_ROOT, 'log', 'traffic.log'), 'a')
  logfile.sync = true
  TRAFFIC_LOG = AuditLogger.new(logfile)
end

