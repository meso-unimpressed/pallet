# 
# This deletes the cached javascript files on server start, so any changes will be reflected
# (files will be re-created at first request)
# 

if ActionController::Base.perform_caching
  begin
    files =  Dir.glob(Rails.root.join('public', 'javascripts', "cached_*.*"))
    files += Dir.glob(Rails.root.join('public', 'stylesheets', "cached_*.*"))

    unless files.empty?
      #puts "Removing cached files:"
      files.each do |path|
        #puts path
        File.delete(path) if File.exists?(path)
      end
    end
  rescue
    puts "*** WARNING: could not update asset cache. Javascripts/Stylesheets may be outdated."
  end
end
