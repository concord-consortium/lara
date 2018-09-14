LightweightStandalone::Application.routes.draw do

  resources :approved_scripts


  resources :projects do
    member do
      get :about
      get :help
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
      get :show_status
      # TODO: dpeprecate this Dashboard route
      get :dashboard_toc, to: redirect(path: "/api/v1/dashboard_toc/sequences/%{id}")
    end
    resources :activities, :controller => 'lightweight_activities', :constraints => { :id => /\d+/, :sequence_id => /\d+/ }, :only => [:show, :summary]
  end

  namespace :embeddable do
    resources :open_response_answers
    resources :multiple_choice_answers
  end

  namespace :c_rater do
    resources :item_settings, :only => [:edit, :update]
    post "/argumentation_blocks/:page_id/create_embeddables" => 'argumentation_blocks#create_embeddables', :as => 'arg_block_create_embeddables'
    post "/argumentation_blocks/:page_id/remove_embeddables" => 'argumentation_blocks#remove_embeddables', :as => 'arg_block_remove_embeddables'
    post "/argumentation_blocks/:page_id/save_feedback/:response_key" => 'argumentation_blocks#save_feedback', :as => 'arg_block_save_feedback', :constraints => { :response_key => /[-\w]{36}/ }
    post "/argumentation_blocks/feedback_on_feedback" => 'argumentation_blocks#feedback_on_feedback', :as => 'arg_block_feedback_on_feedback'
    resources :score_mappings
    post "/argumentation_blocks/report" => 'argumentation_blocks#report'
  end

  namespace :admin do
    resources :users
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

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
      get 'show_status'
      # TODO: dpeprecate this Dashboard route
      get :dashboard_toc, to: redirect(path: "/api/v1/dashboard_toc/activities/%{id}")
    end
    resources :pages, :controller => 'interactive_pages', :constraints => { :id => /\d+/ } do
      member do
        get 'reorder_embeddables'
        post 'add_embeddable'
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
  resources :image_interactives, :constraints => { :id => /\d+/ }, :except => :show
  resources :video_interactives, :constraints => { :id => /\d+/ }, :except => :show do
    member do
      post :add_source
    end
  end

  resources :pages, :controller => 'interactive_pages', :constraints => { :id => /\d+/ }, :except => :create do
    resources :mw_interactives, :controller => 'mw_interactives', :constraints => { :id => /\d+/ }, :except => :show do
      member do
        post 'toggle_visibility'
      end
    end
    resources :image_interactives, :constraints => { :id => /\d+/ }, :except => :show do
      member do
        post 'toggle_visibility'
      end
    end
    resources :video_interactives, :constraints => { :id => /\d+/ }, :except => :show do
      member do
        post 'toggle_visibility'
      end
    end
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
      match 'question_trackers/find_by_activity/:activity_id' =>  "question_trackers#find_by_activity", via: ['get'], defaults: { format: 'json' }
      match 'question_trackers/find_by_sequence/:sequence_id' =>  "question_trackers#find_by_sequence", via: ['get'], defaults: { format: 'json' }

      # For HASBOT C-Rater reports aka HAS Dashboard
      match 'dashboard_runs' => "dashboard#runs", defaults: { format: 'json' }
      match 'dashboard_runs_all' => "dashboard#runs_all", defaults: { format: 'json' }
      match 'dashboard_toc/:runnable_type/:runnable_id' => "dashboard#toc",  defaults: { format: 'json' }

      match "interactive_run_states/:key" => 'interactive_run_states#show', :as => 'show_interactive_run_state', :via => 'get'
      match "interactive_run_states/:key" => 'interactive_run_states#update', :as => 'update_interactive_run_state', :via => 'put'

      match "user_check" => 'user_check#index', defaults: { format: 'json' }

      match 'get_firebase_jwt/:run_id' => 'jwt#get_firebase_jwt', :as => 'get_firebase_jwt', :via => 'post'

      match 'plugin_learner_states/:plugin_id/:run_id' =>
        'plugin_learner_states#load', as: 'show_plugin_learner_state', via: 'get'
      match 'plugin_plugin_learner_state/:plugin_id/:run_id' =>
        'plugin_learner_states#save', as: 'update_plugin_learner_state', via: 'put'
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
  post "/pages/:id/remove_embeddable/:embeddable_id" => 'interactive_pages#remove_embeddable', :as => 'page_remove_embeddable', :constraints => { :id => /\d+/, :embeddable_id => /\d+/ }
  post "/pages/:id/hideshow_embeddable/:embeddable_id" => 'interactive_pages#toggle_hideshow_embeddable', :as => 'page_hideshow_embeddable', :constraints => { :id => /\d+/, :embeddable_id => /\d+/ }
  get "/embeddable/multiple_choice/:id/check" => 'embeddable/multiple_choices#check', :as => 'check_multiple_choice_answer', :constraints => { :id => /\d+/ }
  get "/activities/:activity_id/pages/:id/:response_key" => 'interactive_pages#show', :as => 'page_with_response', :constraints => { :id => /\d+/, :activity_id => /\d+/, :response_key => /[-\w]{36}/ }
  get "/activities/:activity_id/summary/:response_key" => 'lightweight_activities#summary', :as => 'summary_with_response', :constraints => { :activity_id => /\d+/, :response_key => /[-\w]{36}/ }
  get "/activities/:activity_id/resubmit_answers/:response_key" => 'lightweight_activities#resubmit_answers', :as => 'resubmit_answers_for_run', :constraints => { :activity_id => /\d+/, :response_key => /[-\w]{36}/ }
  get "/activities/:activity_id/:response_key" => 'lightweight_activities#show', :as => 'activity_with_response', :constraints => { :activity_id => /\d+/, :response_key => /[-\w]{36}/ }
  get "/activities/:activity_id/single_page/:response_key" => 'lightweight_activities#single_page', :as => 'activity_single_page_with_response', :constraints => { :activity_id => /\d+/, :response_key => /[-\w]{36}/ }
  get "/runs/dirty" => 'runs#dirty', :as => 'dirty_runs'
  get "/runs/details" => 'runs#details', :as => 'run_details'
  # TODO: Depricate this older dashboard route
  get "/runs/dashboard" => 'api/v1/dashboard#runs'
  match "/runs/fix_broken_portal_runs/:run_id" => 'runs#fix_broken_portal_runs', :as => 'fix_broken_portal_runs'
  match "/runs/run_info/:run_id" => 'runs#run_info', :as => 'run_info'


  # Simple image proxy used by Drawing Tool.
  match "/image-proxy" => 'image_proxy#get'
  match "/home/bad_browser" => "home#bad_browser"
  match "/print_headers" => "home#print_headers"

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
