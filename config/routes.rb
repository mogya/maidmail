ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resources :weathers
  map.resources :cities
  map.root :controller => 'top'
  map.logout 'logout', :controller=>'login', :action=>'logout'
  map.connect 'passwd_reset/:user_key', :controller=>'login', :action=>'passwd_reset'

  map.connect ':controller/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end
