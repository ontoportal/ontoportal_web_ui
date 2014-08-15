ActionController::Routing::Routes.draw do |map|
  map.resources :notes

  map.resources :projects

  map.resources :users, :as => :accounts

  map.resources :users, :requirements => { :id => /.*/ }

  map.resources :reviews

  map.resources :mappings

  map.resources :margin_notes

  map.resources :concepts

  map.resources :ontologies, :has_many => :submissions

  map.resources :submissions, :belongs_to => :ontologies

  map.resources :login

  map.resources :admin

  map.resources :subscriptions

  map.resources :recommender

  map.resources :annotator

  map.resources :virtual_appliance

  # The priority is based upon order of creation: first created -> highest priority.

  # You can have the root of your site routed by hooking up ''
  map.connect '', :controller => "home"

  # Top-level pages
  map.connect '/feedback', :controller => 'home', :action => 'feedback'
  map.connect '/account', :controller => 'home', :action => 'account'
  map.connect '/help', :controller => 'home', :action => 'help'
  map.connect '/robots.txt', :controller => 'home', :action => 'robots'
  map.connect '/site_config', :controller => 'home', :action => 'site_config'
  map.connect '/validate_ontology_file', :controller => 'home', :action => 'validate_ontology_file', conditions: {method: :post}
  map.connect '/validate_ontology_file', :controller => 'home', :action => 'validate_ontology_file_show'

  # Analytics endpoint
  map.connect '/analytics', :controller => 'analytics', :action => 'track'

  # Ontologies
  map.connect '/ontologies/view/edit/:id', :controller => 'ontologies', :action => 'edit_view', :requirements => { :id => %r([^/?]+) }
  map.connect '/ontologies/view/new/:id', :controller => 'ontologies', :action => 'new_view'
  map.ontology_virtual '/ontologies/virtual/:ontology', :controller => 'ontologies', :action => 'virtual'
  map.connect '/ontologies/success/:id', :controller => 'ontologies', :action => 'submit_success'
  map.connect '/ontologies/:acronym', controller: 'ontologies', action: 'update', conditions: {method: :post}
  map.connect '/ontologies/:acronym/submissions/:id', controller: 'submissions', action: 'update', conditions: {method: :post}
  map.connect '/ontologies/:ontology_id/submissions/new', :controller => 'submissions', :action => 'new', :ontology_id => /.+/
  map.connect '/ontologies/:ontology_id/submissions', :controller => 'submissions', :action => 'create', :ontology_id => /.+/, conditions: {method: :post}
  map.connect '/ontologies/:acronym/classes/:purl_conceptid', controller: 'ontologies', action: 'show', purl_conceptid: "root"
  map.connect '/ontologies/:acronym/:purl_conceptid', controller: 'ontologies', action: 'show'

  # Analytics
  map.connect '/analytics/:action', :controller => "analytics", :action => /search_result_clicked|user_intention_surveys/

  # New Notes
  map.note '/notes/:id', :controller => 'notes', :action => 'show', :id => /.+/
  map.note_virtual 'ontologies/:ontology/notes/:noteid', :controller => 'notes', :action => 'virtual_show', :noteid => /.+/
  map.note_ajax_single 'notes/ajax/single/:ontology', :controller => 'notes', :action => 'show_single'
  map.note_ajax_single_list 'notes/ajax/single_list/:ontology', :controller => 'notes', :action => 'show_single_list'

  # Ajax
  map.ajax '/ajax/', :controller => 'ajax_proxy', :action => 'get'
  map.connect '/ajax_concepts/:ontology/', :controller => 'concepts', :action => 'show', :requirements => { :id => %r([^/?]+) }
  map.connect '/ajax/class_details', :controller => 'concepts', :action => 'details'
  map.connect "/ajax/mappings/get_concept_table", :controller => "mappings", :action => "get_concept_table"
  map.connect "/ajax/json_ontology", :controller => "ajax_proxy", :action => "json_ontology"
  map.connect "/ajax/json_class", :controller => "ajax_proxy", :action => "json_class"
  map.connect "/ajax/jsonp", :controller => "ajax_proxy", :action => "jsonp"
  map.connect "/ajax/recaptcha", :controller => "ajax_proxy", :action => "recaptcha"
  map.connect "/ajax/loading_spinner", :controller => "ajax_proxy", :action => "loading_spinner"
  map.connect "/ajax/notes/delete", :controller => "notes", :action => "destroy"
  map.connect "/ajax/notes/concept_list", :controller => "notes", :action => "show_concept_list"
  map.connect "/ajax/classes/label", :controller => "concepts", :action => "show_label"
  map.connect "/ajax/classes/definition", :controller => "concepts", :action => "show_definition"
  map.connect "/ajax/classes/treeview", :controller => "concepts", :action => "show_tree"
  map.connect '/ajax/biomixer', :controller => 'concepts', :action => 'biomixer'

  # User
  map.logout '/logout', :controller => 'login', :action => 'destroy'
  map.lost_pass '/lost_pass', :controller => 'login', :action => 'lost_password'
  map.lost_pass '/reset_password', :controller => 'login', :action => 'reset_password'
  map.custom_ontologies '/accounts/:id/custom_ontologies', :controller => 'users', :action => 'custom_ontologies'
  map.connect '/login_as/:login_as', :controller => 'login', :action => 'login_as'

  # Resource Index
  map.obr_details '/res_details/:id', :controller => 'resources', :action => 'details'
  map.obr '/resources/:ontology/:id', :controller => 'resources', :action => 'show'
  map.obrpage '/respage/', :controller => 'resources', :action => 'page'
  map.connect '/resource_index/resources', :controller => 'resource_index', :action => 'index'
  map.connect '/resource_index/resources/:resource_id', :controller => 'resource_index', :action => 'index'
  map.connect '/resource_index/:action', :controller => "resource_index", :action => /element_annotations|results_paginate|resources_table/
  map.connect '/resource_index/search_classes', :controller => "resource_index", :action => 'search_classes'
  map.resources :resource_index

  # History
  map.remove_tab '/tab/remove/:ontology',:controller => 'history', :action => 'remove'
  map.update_tab '/tab/update/:ontology/:concept', :controller => 'history', :action=>'update'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.jam 'jambalaya/:ontology/:id', :controller => 'visual', :action => 'jam'

  # Admin
  map.connect '/admin/clearcache', controller: 'admin', action: 'clearcache', conditions: {method: :post}
  map.connect '/admin/resetcache', controller: 'admin', action: 'resetcache', conditions: {method: :post}

  #####
  ## OLD ROUTES
  ## All of these should redirect to new addresses in the controller method or using the redirect controller
  #####

  # Redirects from old URL locations
  map.connect '/annotate', :controller => 'redirect', :url => '/annotator'
  map.connect '/all_resources', :controller =>'redirect', :url => '/resources'
  map.connect '/resources', :controller => 'redirect', :url => '/resource_index'
  map.connect '/visconcepts/:ontology/', :controller => 'redirect', :url => '/visualize/'
  map.connect '/ajax/terms/label', :controller => 'redirect', :url => '/ajax/classes/label'
  map.connect '/ajax/terms/definition', :controller => 'redirect', :url => '/ajax/classes/definition'
  map.connect '/ajax/terms/treeview', :controller => 'redirect', :url => '/ajax/classes/treeview'
  map.connect '/ajax/term_details/:ontology', :controller => 'redirect', :url => '/ajax/class_details'
  map.connect "/ajax/json_term", :controller => 'redirect', :url => '/ajax/json_class'

  # Visualize
  map.virtual_visualize '/visualize/virtual/:ontology', :controller => 'concepts', :action => 'virtual', :requirements => { :id => %r([^/?]+), :conceptid => %r([^/?]+) }
  map.virtual_uri '/visualize/virtual/:ontology/:id', :controller => 'concepts', :action => 'virtual', :requirements => { :id => %r([^/?]+) }
  map.visualize '/visualize/:ontology', :controller => 'ontologies', :action =>'visualize', :requirements => { :ontology => %r([^/?]+) }
  map.uri '/visualize/:ontology/:conceptid', :controller => 'ontologies', :action => 'visualize', :requirements => { :ontology => %r([^/?]+), :conceptid => %r([^/?]+) }
  map.visualize_concept '/visualize', :controller => 'ontologies', :action => 'visualize', :requirements => { :ontology => %r([^/?]+), :id => %r([^/?]+),
                                                                                                              :ontologyid => %r([^/?]+), :conceptid => %r([^/?]+) }
  map.flexviz '/flexviz/:ontologyid', :controller => 'concepts', :action => 'flexviz', :requirements => { :ontologyid => %r([^/?]+) }
  map.connect '/exhibit/:ontology/:id', :controller => 'concepts', :action=>'exhibit'

  # Virtual
  map.virtual_ont '/virtual/:ontology', :controller => 'concepts', :action => 'virtual', :requirements => { :ontology => %r([^/?]+) }
  map.virtual '/virtual/:ontology/:conceptid', :controller => 'concepts', :action => 'virtual', :requirements => { :ontology => %r([^/?]+), :conceptid => %r([^/?]+) }
end
