ActionController::Routing::Routes.draw do |map|
  map.resources :users

  map.resources :mappings

  map.resources :margin_notes

  map.resources :concepts

  map.resources :ontologies
  
  map.resources :login

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:

  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
 
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
   map.connect '', :controller => "home"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  
  
  map.logout '/logout',:controller=>'login',:action=>'destroy'
  map.visualize '/visualize/:ontology', :controller=>'ontologies', :action =>'visualize',:requirements => { :ontology => %r([^/?]+) }
  map.uri '/visualize/:ontology/:id', :controller => 'concepts', :action => 'show',:requirements => { :ontology => %r([^/?]+) ,:id => %r([^/?]+)}
  map.ontology '/ontology/:ontology', :controller => 'ontologies', :action => 'show',:requirements => { :ontology => %r([^/?]+) }
  map.remove_tab '/tab/remove/:ontology',:controller=>'history',:action=>'remove'
  map.update_tab '/tab/update/:ontology/:concept',:controller=>'history',:action=>'update'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.jam 'jambalaya/:ontology/:id', :controller => 'visual', :action => 'jam'
end
