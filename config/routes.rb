BioportalWebUi::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

  resources :notes

  resources :projects

  resources :users, :as => :accounts, :requirements => { :id => /.+/ }

  resources :reviews

  resources :mappings

  resources :margin_notes

  resources :concepts

  resources :ontologies do 
    resources :submissions
  end

  resources :login

  resources :admin

  resources :subscriptions

  resources :recommender

  resources :annotator

  resources :virtual_appliance

  match '' => 'home#index'
  
  # Top-level pages
  match '/feedback' => 'home#feedback'
  match '/account' => 'home#account'
  match '/help' => 'home#help'
  match '/robots.txt' => 'home#robots'
  match '/site_config' => 'home#site_config'
  match '/validate_ontology_file' => 'home#validate_ontology_file', :via => :post
  match '/validate_ontology_file' => 'home#validate_ontology_file_show'
  match '/layout_partial/:partial' => 'home#render_layout_partial'
  
  # Analytics endpoint
  match '/analytics' => 'analytics#track'

  # Ontologies
  match '/ontologies/view/edit/:id' => 'ontologies#edit_view', :constraints => { :id => /[^\/?]+/ }
  match '/ontologies/view/new/:id' => 'ontologies#new_view'
  match '/ontologies/virtual/:ontology' => 'ontologies#virtual', :as => :ontology_virtual
  match '/ontologies/success/:id' => 'ontologies#submit_success'
  match '/ontologies/:acronym' => 'ontologies#update', :via => :post
  match '/ontologies/:acronym/submissions/:id' => 'submissions#update', :via => :post
  match '/ontologies/:ontology_id/submissions/new' => 'submissions#new', :ontology_id => /.+/
  match '/ontologies/:ontology_id/submissions' => 'submissions#create', :ontology_id => /.+/, :via => :post
  match '/ontologies/:acronym/classes/:purl_conceptid' => 'ontologies#show', :purl_conceptid => 'root'
  match '/ontologies/:acronym/:purl_conceptid' => 'ontologies#show'

  # Analytics
  match '/analytics/:action' => 'analytics#(?-mix:search_result_clicked|user_intention_surveys)'

  # New Notes
  match '/notes/:id' => 'notes#show', :as => :note, :id => /.+/
  match 'ontologies/:ontology/notes/:noteid' => 'notes#virtual_show', :as => :note_virtual, :noteid => /.+/
  match 'notes/ajax/single/:ontology' => 'notes#show_single', :as => :note_ajax_single
  match 'notes/ajax/single_list/:ontology' => 'notes#show_single_list', :as => :note_ajax_single_list

  # Ajax
  match '/ajax/' => 'ajax_proxy#get', :as => :ajax
  match '/ajax_concepts/:ontology/' => 'concepts#show', :constraints => { :id => /[^\/?]+/ }
  match '/ajax/class_details' => 'concepts#details'
  match '/ajax/mappings/get_concept_table' => 'mappings#get_concept_table'
  match '/ajax/json_ontology' => 'ajax_proxy#json_ontology'
  match '/ajax/json_class' => 'ajax_proxy#json_class'
  match '/ajax/jsonp' => 'ajax_proxy#jsonp'
  match '/ajax/recaptcha' => 'ajax_proxy#recaptcha'
  match '/ajax/loading_spinner' => 'ajax_proxy#loading_spinner'
  match '/ajax/notes/delete' => 'notes#destroy'
  match '/ajax/notes/concept_list' => 'notes#show_concept_list'
  match '/ajax/classes/label' => 'concepts#show_label'
  match '/ajax/classes/definition' => 'concepts#show_definition'
  match '/ajax/classes/treeview' => 'concepts#show_tree'
  match '/ajax/properties/tree' => 'concepts#property_tree'
  match '/ajax/biomixer' => 'concepts#biomixer'

  # User
  match '/logout' => 'login#destroy', :as => :logout
  match '/lost_pass' => 'login#lost_password', :as => :lost_pass
  match '/reset_password' => 'login#reset_password', :as => :lost_pass
  match '/accounts/:id/custom_ontologies' => 'users#custom_ontologies', :as => :custom_ontologies
  match '/login_as/:login_as' => 'login#login_as'

  # Resource Index
  match '/res_details/:id' => 'resources#details', :as => :obr_details
  match '/resources/:ontology/:id' => 'resources#show', :as => :obr
  match '/respage/' => 'resources#page', :as => :obrpage
  match '/resource_index/resources' => 'resource_index#index'
  match '/resource_index/resources/:resource_id' => 'resource_index#index'
  match '/resource_index/:action' => 'resource_index#(?-mix:element_annotations|results_paginate|resources_table)'
  match '/resource_index/search_classes' => 'resource_index#search_classes'
  resources :resource_index

  # History
  match '/tab/remove/:ontology' => 'history#remove', :as => :remove_tab
  match '/tab/update/:ontology/:concept' => 'history#update', :as => :update_tab

  # Install the default route as the lowest priority.
  match '/:controller(/:action(/:id))'
  match 'jambalaya/:ontology/:id' => 'visual#jam', :as => :jam

  # Admin
  match '/admin/clearcache' => 'admin#clearcache', :via => :post
  match '/admin/resetcache' => 'admin#resetcache', :via => :post
  
  #####
  ## OLD ROUTES
  ## All of these should redirect to new addresses in the controller method or using the redirect controller
  #####

  # Redirects from old URL locations
  match '/annotate' => 'redirect#index', :url => '/annotator'
  match '/all_resources' => 'redirect#index', :url => '/resources'
  match '/resources' => 'redirect#index', :url => '/resource_index'
  match '/visconcepts/:ontology/' => 'redirect#index', :url => '/visualize/'
  match '/ajax/terms/label' => 'redirect#index', :url => '/ajax/classes/label'
  match '/ajax/terms/definition' => 'redirect#index', :url => '/ajax/classes/definition'
  match '/ajax/terms/treeview' => 'redirect#index', :url => '/ajax/classes/treeview'
  match '/ajax/term_details/:ontology' => 'redirect#index', :url => '/ajax/class_details'
  match '/ajax/json_term' => 'redirect#index', :url => '/ajax/json_class'

  # Visualize
  match '/visualize/virtual/:ontology' => 'concepts#virtual', :as => :virtual_visualize, :constraints => { :id => /[^\/?]+/, :conceptid => /[^\/?]+/ }
  match '/visualize/virtual/:ontology/:id' => 'concepts#virtual', :as => :virtual_uri, :constraints => { :id => /[^\/?]+/ }
  match '/visualize/:ontology' => 'ontologies#visualize', :as => :visualize, :constraints => { :ontology => /[^\/?]+/ }
  match '/visualize/:ontology/:conceptid' => 'ontologies#visualize', :as => :uri, :constraints => { :ontology => /[^\/?]+/, :conceptid => /[^\/?]+/ }
  match '/visualize' => 'ontologies#visualize', :as => :visualize_concept, :constraints => { :ontology => /[^\/?]+/, :id => /[^\/?]+/, :ontologyid => /[^\/?]+/, :conceptid => /[^\/?]+/ }

  match '/flexviz/:ontologyid' => 'concepts#flexviz', :as => :flexviz, :constraints => { :ontologyid => /[^\/?]+/ }
  match '/exhibit/:ontology/:id' => 'concepts#exhibit'
  
  # Virtual
  match '/virtual/:ontology' => 'concepts#virtual', :as => :virtual_ont, :constraints => { :ontology => /[^\/?]+/ }
  match '/virtual/:ontology/:conceptid' => 'concepts#virtual', :as => :virtual, :constraints => { :ontology => /[^\/?]+/, :conceptid => /[^\/?]+/ }
end
