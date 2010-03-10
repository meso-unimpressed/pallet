ActionController::Routing::Routes.draw do |map|
  map.root :controller => "pallets"

  map.connect 'pallet_global_configs', :controller => 'pallet_global_configs', :action => 'edit'

  map.connect ':controller/auto_complete_for_user_association', :action => 'auto_complete_for_user_association'

  # nginx upload module support
  map.connect 'upload', :controller => 'pallets', :action => 'upload'
  map.connect 'dialog_upload/:id', :controller => 'pallets', :action => 'dialog_upload'

  map.resources :pallet_global_configs
  map.resources :pallets, :member => { :download_file => :get,
                                       :rename        => :any, # TODO: change to put
                                       :upload        => :post }

  # AUTH routes:
  map.resources :user_sessions
  map.resources :users
  map.resources :roles

  # named routes: login_url/login_path, ...
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"


  map.connect 'oca/:oca_token', :controller => 'pallets', :action => 'show'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  if Rails.env == 'production'
    map.error '*url', :controller => 'pallets'
  end
end
