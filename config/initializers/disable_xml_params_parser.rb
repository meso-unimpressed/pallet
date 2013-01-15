# fix for CVE-2013-0156
# https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/61bkgvnSGTQ
#
# save this as config/initializers/disable_xml_params_parser
#
# source: https://gist.github.com/4505417

def rails_between(min, max)
  Gem::Version.new(Rails::VERSION::STRING) >= Gem::Version.new(min) && Gem::Version.new(Rails::VERSION::STRING) <= Gem::Version.new(max)
end

if rails_between('3.0.0', '3.0.18') || rails_between('3.1.0', '3.1.9') || rails_between('3.2.0', '3.2.10')
  ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
end

if rails_between('2.0.0', '2.3.14')
  ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING.delete('symbol')
  ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING.delete('yaml')
  ActionController::Base.param_parsers.delete(Mime::XML)
end
