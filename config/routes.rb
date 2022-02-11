LightweightStandalone::Application.routes.draw do

  resources :library_interactives, :except => [:show] do
    member do
      get :migrate
      put :migrate
    end
  end

  resources :approved_scripts

  resources :projects do
    member do
      get :about
      get :contact_us
    end
  end

  resources :themes
  root :to => 'home#home'

  resources :question_trackers do
    member do
      post 'add_embeddable'
      post 'replace_master'
    end
  end

  namespace :embeddable do
    resources :image_question_answers
  end

  namespace :embeddable do
    resources :image_questions
  end

  resources :sequences, :constraints => { :id => /\d+/ } do
    member do
      post :add_activity
      post :remove_activity
      post :remote_duplicate
      get :reorder_activities
      get :print_blank
      get :publish
      get :duplicate
      get :export
      get :export_for_portal
      get :show_status
      # TODO: dpeprecate this Dashboard route
      get :dashboard_toc, to: redirect(path: "/api/v1/dashboard_toc/sequences/%{id}")
    end
    resources :activities, :controller => 'lightweight_activities', :constraints => { :id => /\d+/, :sequence_id => /\d+/ }, :only => [:show, :summary] do
      member do
        get :preview
      end
    end
  end

  namespace :embeddable do
    resources :open_response_answers
    resources :multiple_choice_answers
  end

  namespace :c_rater do
    resources :item_settings, :only => [:edit, :update]
    post "/argumentation_blocks/:page_id/create_embeddables" => 'argumentation_blocks#create_embeddables', :as => 'arg_block_create_embeddables'
    post "/argumentation_blocks/:page_id/remove_embeddables" => 'argumentation_blocks#remove_embeddables', :as => 'arg_block_remove_embeddables'
    post "/argumentation_blocks/:page_id/save_feedback/:run_key" => 'argumentation_blocks#save_feedback', :as => 'arg_block_save_feedback', :constraints => { :run_key => /[-\w]{36}/ }
    post "/argumentation_blocks/feedback_on_feedback" => 'argumentation_blocks#feedback_on_feedback', :as => 'arg_block_feedback_on_feedback'
    resources :score_mappings
    post "/argumentation_blocks/report" => 'argumentation_blocks#report'
  end

  namespace :admin do
    resources :users
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  resources :sections, :controller => 'sections', :constraints => { :id => /\d+/ }

  resources :activities, :controller => 'lightweight_activities', :constraints => { :id => /\d+/ } do
    member do
      get 'reorder_pages'
      get 'single_page'
      get 'print_blank'
      get 'summary'
      get 'resubmit_answers'
      get 'publish'
      get 'duplicate'
      post 'remote_duplicate'
      get 'preview'
      get 'export'
      get 'export_for_portal'
      get 'show_status'
      post 'add_plugin'
      # TODO: dpeprecate this Dashboard route
      get :dashboard_toc, to: redirect(path: "/api/v1/dashboard_toc/activities/%{id}")
    end

    resources :pages, :controller => 'interactive_pages', :constraints => { :id => /\d+/ } do
      member do
        get 'reorder_embeddables'
        post 'add_embeddable'
        post 'add_section'
        post 'delete_section'
        get  'add_tracked'
        get 'move_up', :controller => 'lightweight_activities'
        get 'move_down', :controller => 'lightweight_activities'
        get 'preview'
      end
    end
    resources :runs, :only => [:index, :show ], :constraints => { :id => /[-\w]{36}/, :activity_id => /\d+/ }
  end

  resources :runs, :only => [:index, :show ], :constraints => { :id => /[-\w]{36}/ } do
    resource :global_interactive_state, :only => [:create]
    collection do
      post 'unauthorized_feedback'
    end
  end

  # These don't need index or show pages - though there might be something to be said for an
  # index .xml file as a feed for select menus - but they need create-update-delete.
  resources :mw_interactives, :controller => 'mw_interactives', :constraints => { :id => /\d+/ }, :except => :show
  resources :managed_interactives, :controller => 'managed_interactives', :constraints => { :id => /\d+/ }, :except => :show
  resources :image_interactives, :constraints => { :id => /\d+/ }, :except => :show
  resources :video_interactives, :constraints => { :id => /\d+/ }, :except => :show do
    member do
      post :add_source
    end
  end

  resources :pages, :controller => 'interactive_pages', :constraints => { :id => /\d+/ }, :except => :create do
    member do
      get 'preview'
    end
  end

  # the in-place editor needed interactive_page_path
  resources :pages, :as => 'interactive_pages', :controller => 'interactive_pages', :constraints => { :id => /\d+/ }, :except => [:new, :create]

  resources :plugins
  namespace :embeddable do
    # When new embeddables are supported, they should be added here.
    resources :multiple_choices do
      member do
        post :add_choice
      end
    end
    resources :xhtmls
    resources :external_scripts
    resources :embeddable_plugins
    resources :open_responses
    resources :labbooks
    resources :labbook_answers, :only => [:update]
  end

  namespace :api do
    namespace :v1 do
      # For UW style tracked question reports (longitudinal reports)
      resources :question_trackers, only: [:index] do
        match 'report' =>  "question_trackers#report", via: ['get','post', 'put'], defaults: { format: 'json' }
      end

      resources :activities, :controller => 'lightweight_activities', only: [:show, :destroy] do
        member do
          get :report_structure
        end
      end
      resources :sequences, :controller => 'sequences', only: [:show, :destroy] do
        member do
          get :report_structure
        end
      end

      match 'import' => 'import#import', :via => 'post'

      match 'question_trackers/find_by_activity/:activity_id' =>  "question_trackers#find_by_activity", via: ['get'], defaults: { format: 'json' }
      match 'question_trackers/find_by_sequence/:sequence_id' =>  "question_trackers#find_by_sequence", via: ['get'], defaults: { format: 'json' }

      # For HASBOT C-Rater reports aka HAS Dashboard
      match 'dashboard_runs' => "dashboard#runs", defaults: { format: 'json' }
      match 'dashboard_runs_all' => "dashboard#runs_all", defaults: { format: 'json' }
      match 'dashboard_toc/:runnable_type/:runnable_id' => "dashboard#toc",  defaults: { format: 'json' }

      match "interactive_run_states/:key" => 'interactive_run_states#show', :as => 'show_interactive_run_state', :via => 'get'
      match "interactive_run_states/:key" => 'interactive_run_states#update', :as => 'update_interactive_run_state', :via => 'put'

      match "user_check" => 'user_check#index', defaults: { format: 'json' }

      match 'get_firebase_jwt(/:run_id)' => 'jwt#get_firebase_jwt', :as => 'get_firebase_jwt', :via => 'post'
      match 'get_portal_jwt(/:run_id)' => 'jwt#get_portal_jwt', :as => 'get_portal_jwt', :via => 'post'
      match 'get_interactive_list/:id' => 'interactive_pages#get_interactive_list', :as => 'get_interactive_list', :via => 'get'

      # New Section (React) authoring routes:
      match 'get_page_sections/:id' => 'interactive_pages#get_sections', :as => 'get_page_sections', :via => 'get'
      # This will handle the delete case too ...
      match 'set_page_sections/:id' => 'interactive_pages#set_sections', :as => 'set_page_sections', :via => 'put'
      match 'create_page_section/:id' => 'interactive_pages#create_section', :as => 'create_page_section', :via => 'post'
      match 'copy_page_section/:id' => 'interactive_pages#copy_section', :as => 'copy_page_section', :via => 'post'
      match 'update_page_section/:id' => 'interactive_pages#update_section', :as => 'update_page_section', :via => 'post'

      match 'create_page_item/:id' => 'interactive_pages#create_page_item', :as => 'create_page_item', :via => 'post'
      match 'update_page_item/:id' => 'interactive_pages#update_page_item', :as => 'update_page_item', :via => 'post'
      match 'delete_page_item/:id' => 'interactive_pages#delete_page_item', :as => 'delete_page_item', :via => 'post'
      match 'copy_page_item/:id' => 'interactive_pages#copy_page_item', :as => 'copy_page_item', :via => 'post'

      match 'get_library_interactives_list' => 'interactive_pages#get_library_interactives_list', :as => 'get_library_interactives_list', :via => 'get'
      match 'get_portal_list' => 'interactive_pages#get_portal_list', :as => 'get_portal_list', :via => 'get'

      match 'get_pages/:activity_id' => 'interactive_pages#get_pages', :as => 'get_page_list', :via => 'get'
      match 'get_page/:id' => 'interactive_pages#get_page', :as => 'get_page', :via => 'get'
      match 'delete_page/:id' => 'interactive_pages#delete_page', as: 'delete_page', :via => 'post'
      match 'create_page/:activity_id' => 'interactive_pages#create_page', :as => 'create_page', :via => 'post'
      match 'update_page/:id' => 'interactive_pages#update_page', :as => 'update_page', :via => 'put'
      match 'copy_page/:id' => 'interactive_pages#copy_page', :as => 'copy_page', :via => 'post'
      match 'get_preview_url/:id' => 'interactive_pages#get_preview_url', :as => 'get_preview_url', :via => 'get'
      
      match 'plugin_learner_states/:plugin_id/:run_id' =>
        'plugin_learner_states#load', as: 'show_plugin_learner_state', via: 'get'
      match 'plugin_plugin_learner_state/:plugin_id/:run_id' =>
        'plugin_learner_states#save', as: 'update_plugin_learner_state', via: 'put'

      match 'plugins/:plugin_id/author_data' => 'plugins#load_author_data', as: 'show_plugin_author_data', via: 'get'
      match 'plugins/:plugin_id/author_data' => 'plugins#save_author_data', as: 'update_plugin_author_data', via: 'put'

      match 'projects' => 'projects#index', as: 'index', via: 'get'
      match 'projects' => 'projects#create', as: 'create', via: 'post'
      match 'projects/:id' => 'projects#show', as: 'show', via: 'get'
      match 'projects/:id' => 'projects#update', as: 'update', via: 'post'
      match 'delete_project/:id' => 'projects#destroy', as: 'destroy', via: 'post'
      match 'themes' => 'themes#index', as: 'index', via: 'get'
    end
  end

  match "/publications/show_status/:publishable_type/:publishable_id"=> 'publications#show_status', :as => 'publication_show_status'
  match "/publications/autopublishing_status/:publishable_type/:publishable_id"=> 'publications#autopublishing_status', :as => 'publication_autopublishing_status'
  match "/publications/add/:publishable_type/:publishable_id"=> 'publications#add_portal', :as => 'publication_add_portal'
  match "/publications/publish/:publishable_type/:publishable_id"=> 'publications#publish', :as => 'publication_publish'
  match "/publications/publish_to_other_portals/:publishable_type/:publishable_id"=> 'publications#publish_to_other_portals', :as => 'publication_publish_to_other_portals'
  match "/import" => 'import#import_status', :as => 'import_status', :via => 'get'
  match "/import" => 'import#import', :as => 'import', :via => 'post'
  match "/import/import_portal_activity" => 'import#import_portal_activity', :as => 'import_portal_activity', :via => 'post', :defaults => { format: 'json' }

  # These routes didn't work as nested resources
  delete "/embeddable/multiple_choice/:id/remove_choice/:choice_id" => 'embeddable/multiple_choices#remove_choice', :as => 'remove_choice_embeddable_multiple_choice', :constraints => { :id => /\d+/, :choice_id => /\d+/ }
  delete "/video_interactives/:id/remove_source/:source_id" => "video_interactives#remove_source", :as => 'remove_source_video_interactive', :constraints => { :id => /\d+/, :source_id => /\d+/ }
  post "/remove_page_item/:page_item_id" => 'interactive_pages#remove_page_item', :as => 'remove_page_item', :constraints => { :page_item_id => /\d+/ }
  delete "/remove_section/:section_id" => 'interactive_pages#remove_section', :as => 'remove_section', :constraints => { :section_item_id => /\d+/ }
  post "/hideshow_page_item/:page_item_id" => 'interactive_pages#toggle_hideshow_page_item', :as => 'toggle_hideshow_page_item', :constraints => { :page_item_id => /\d+/ }
  get "/embeddable/multiple_choice/:id/check" => 'embeddable/multiple_choices#check', :as => 'check_multiple_choice_answer', :constraints => { :id => /\d+/ }
  get "/activities/:activity_id/pages/:id/:run_key" => 'interactive_pages#show', :as => 'page_with_run', :constraints => { :id => /\d+/, :activity_id => /\d+/, :run_key => /[-\w]{36}/ }
  get "/activities/:activity_id/summary/:run_key" => 'lightweight_activities#summary', :as => 'summary_with_run', :constraints => { :activity_id => /\d+/, :run_key => /[-\w]{36}/ }
  get "/activities/:activity_id/resubmit_answers/:run_key" => 'lightweight_activities#resubmit_answers', :as => 'resubmit_answers_for_run', :constraints => { :activity_id => /\d+/, :run_key => /[-\w]{36}/ }
  get "/activities/:id/:run_key" => 'lightweight_activities#show', :as => 'activity_with_run', :constraints => { :activity_id => /\d+/, :run_key => /[-\w]{36}/ }
  get "/activities/:id/single_page/:run_key" => 'lightweight_activities#single_page', :as => 'activity_single_page_with_run', :constraints => { :id => /\d+/, :run_key => /[-\w]{36}/ }
  get "/runs/dirty" => 'runs#dirty', :as => 'dirty_runs'
  get "/runs/details" => 'runs#details', :as => 'run_details'
  get "/sequences/:sequence_id/activities/:id/:run_key" => 'lightweight_activities#show', :as => 'sequence_activity_with_run', :constraints => { :sequence_id => /\d+/, :activity_id => /\d+/, :run_key => /[-\w]{36}/ }
  get "/sequences/:sequence_id/activities/:activity_id/single_page/:run_key" => 'lightweight_activities#single_page', :as => 'sequence_activity_single_page_with_run', :constraints => { :sequence_id => /\d+/, :activity_id => /\d+/, :run_key => /[-\w]{36}/ }
  get "/sequences/:sequence_id/activities/:activity_id/pages/:id" => 'interactive_pages#show', :as => 'sequence_page', :constraints => { :id => /\d+/, :sequence_id => /\d+/, :activity_id => /\d+/ }
  get "/sequences/:sequence_id/activities/:activity_id/pages/:id/:run_key" => 'interactive_pages#show', :as => 'sequence_page_with_run', :constraints => { :id => /\d+/, :sequence_id => /\d+/, :activity_id => /\d+/, :run_key => /[-\w]{36}/ }
  get "/sequences/:sequence_id/activities/:activity_id/summary/:run_key" => 'lightweight_activities#summary', :as => 'sequence_summary_with_run', :constraints => { :sequence_id => /\d+/, :activity_id => /\d+/, :run_key => /[-\w]{36}/ }
  get "/sequences/:id/sequence_run/:sequence_run_key" => 'sequences#show', :as => 'sequence_with_sequence_run_key', :constraints => { :id => /\d+/, :sequence_id => /\d+/, :activity_id => /\d+/, :run_key => /[-\w]{36}/ }
  # TODO: Depricate this older dashboard route
  get "/runs/dashboard" => 'api/v1/dashboard#runs'
  match "/runs/fix_broken_portal_runs/:run_id" => 'runs#fix_broken_portal_runs', :as => 'fix_broken_portal_runs'
  match "/runs/run_info/:run_id" => 'runs#run_info', :as => 'run_info'


  # Simple image proxy used by Drawing Tool.
  match "/image-proxy" => 'image_proxy#get'
  match "/home/bad_browser" => "home#bad_browser"
  match "/print_headers" => "home#print_headers"

  # Remote duplicate
  match "/remote_duplicate" => "home#remote_duplicate"

  # Web interface to show the delayed jobs for admins
  # unfortunately this route has caused other route constraints to stop working?
  match "/delayed_job" => DelayedJobWeb, :anchor => false, :via => [:get, :post], :constraints => lambda { |request|
    warden = request.env['warden']
    warden.user && warden.user.admin?
  }

  match "/dev/test_argblock" => 'dev#test_argblock', :as => 'test_argblock'
  match "/dev/test_mail" => 'dev#test_mail', :as => 'test_mail'
  match "/dev/test_exception" => 'dev#test_error', :as => 'test_exception'
  match "/dev/test_error" => 'dev#test_error', :as => 'test_error'
end
