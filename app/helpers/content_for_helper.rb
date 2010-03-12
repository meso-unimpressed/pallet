module ContentForHelper
  def title_customized_by_view(view_title, prefix = '', default = nil, suffix = '', separator = ' - ')
    title = prefix
    unless view_title.blank?
      title << separator << view_title
    else
      title << separator unless default.blank?
      title << default
    end
    title << suffix
  end
  
  def page_title(title)
    content_for :title do title end
  end
  
  def custom_stylesheets(stylesheets)
    includes = []
    stylesheets.each { |sheet| includes << stylesheet_link_tag(sheet) }
    content_for :stylesheets do includes.join("\n    ") end
  end

  # does only work for views, not for layouts or partials rendered in layouts!
  #
  # WARNING: This function seems to create the cache file only once.
  #          Use refresh_asset_cache initializer to solve this problem!
  #
  def custom_javascripts(javascripts, plain_script = '')
    id = 'cached_unobtrusive_' + Digest::MD5.hexdigest([javascripts].compact.join(','))
    #logger.debug "\n===> #{javascripts.to_yaml}\n"
    #logger.debug "\n===> #{id}\n"
    content_for :javascripts do
      javascript_include_tag(javascripts, :cache => id) + plain_script
    end

    # here the old plain uncached version:
    #includes = []
    #javascripts.each { |script| includes << javascript_include_tag(script) }
    #content_for :javascripts do includes.join("\n    ") + "\n    " + plain_script end
  end
  
end
