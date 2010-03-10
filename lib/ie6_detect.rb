# 
# IE6Detect - code taken from ie_no_more by Michael Leung
# http://github.com/mleung/ie_no_more
# 

module IE6Detect
  
  def hide_if_ie6
    yield unless is_ie6?
  end
  
  def show_if_ie6
    yield if is_ie6?
  end
  
  def is_ie6?
    request.env["HTTP_USER_AGENT"] =~ /MSIE 6+?/
  end
  
end

