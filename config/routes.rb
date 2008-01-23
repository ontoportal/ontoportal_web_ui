ActionController::Routing::Routes.draw do |map|
  map.resources :users

  map.resources :mappings

  map.resources :margin_notes

  map.resources :concepts

  map.resources :ontologies

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

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.visualize 'visualize/:ontology', :controller=>'ontologies', :action =>'visualize',:requirements => { :ontology => %r([^/?]+) }
  map.uri '/ont/:ontology/:id', :controller => 'concepts', :action => 'show',:requirements => { :ontology => %r([^/?]+) ,:id => %r([^/?]+)}
  map.ontology '/ont/:ontology', :controller => 'ontologies', :action => 'show',:requirements => { :ontology => %r([^/?]+) }
 
  #map.jam 'jambalaya/:ontology/:id', :controller => 'visual', :action => 'jam'
end
