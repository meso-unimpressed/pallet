# 
# This deletes the cached javascript files on server start, so any changes will be reflected
# (files will be re-created at first request)
# 

if Rails.env == 'production'
  begin
    asset_files = ['javascripts/cached_javascripts.js',
                   'stylesheets/cached_stylesheets.css']
    
    asset_files.each do |cache_file|
      path = Rails.root.join('public', cache_file)
      File.delete(path) if File.exists?(path)
    end
  rescue
    puts "*** WARNING: could not update asset cache. Javascripts/Stylesheets may be outdated."
  end
end
