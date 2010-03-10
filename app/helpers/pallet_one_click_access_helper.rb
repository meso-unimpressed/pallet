module PalletOneClickAccessHelper
  
  def token_url(oca)
    return url_for(:controller => 'oca', :only_path => false, :action => oca.token)
  end


  def token_link(oca)
    url = token_url(oca)
    return link_to(url, url)
  end

end
