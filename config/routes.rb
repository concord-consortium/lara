LightweightStandalone::Application.routes.draw do

  resources :projects

  resources :themes

  root :to => 'home#home'

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
      get :reorder_activities
      get :publish
      get :duplicate
      get :export
      get :show_status
    end
    resources :activities, :controller => 'lightweight_activities', :constraints => { :id => /\d+/, :sequence_id => /\d+/ }, :only => [:show, :summary]
  end

  namespace :embeddable do
    resources :open_response_answers
    resources :multiple_choice_answers
  end

  namespace :admin do
    resources :users
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  resources :activities, :controller => 'lightweight_activities', :constraints => { :id => /\d+/ } do
    member do
      get 'reorder_pages'
      get 'summary'
      get 'resubmit_answers'
      get 'publish'
      get 'duplicate'
      get 'preview'
      get 'export'
      get 'show_status'
    end
    resources :pages, :controller => 'interactive_pages', :constraints => { :id => /\d+/ } do
      member do
        get 'reorder_embeddables'
        post 'add_embeddable'
        post 'add_interactive'
        get 'move_up', :controller => 'lightweight_activities'
        get 'move_down', :controller => 'lightweight_activities'
        get 'preview'
      end
    end
    resources :runs, :only => [:index, :show ], :constraints => { :id => /[-\w]{36}/, :activity_id => /\d+/ }
  end

  resources :runs, :only => [:index, :show ], :constraints => { :id => /[-\w]{36}/ }
  resources :interactive_run_states
  # These don't need index or show pages - though there might be something to be said for an
  # index .xml file as a feed for select menus - but they need create-update-delete.
  resources :mw_interactives, :controller => 'mw_interactives', :constraints => { :id => /\d+/ }, :except => :show
  resources :image_interactives, :constraints => { :id => /\d+/ }, :except => :show
  resources :video_interactives, :constraints => { :id => /\d+/ }, :except => :show do
    member do
      post :add_source
    end
  end

  # This is so we can build the InteractiveItem at the same time as the Interactive
  resources :pages, :controller => 'interactive_pages', :constraints => { :id => /\d+/ }, :except => :create do
    resources :mw_interactives, :controller => 'mw_interactives', :constraints => { :id => /\d+/ }, :except => :show
    resources :image_interactives, :constraints => { :id => /\d+/ }, :except => :show
    resources :video_interactives, :constraints => { :id => /\d+/ }, :except => :show
    member do
      get 'preview'
    end
  end

  # the in-place editor needed interactive_page_path
  resources :pages, :as => 'interactive_pages', :controller => 'interactive_pages', :constraints => { :id => /\d+/ }, :except => [:new, :create]

  namespace :embeddable do
    # When new embeddables are supported, they should be added here.
    resources :multiple_choices do
      member do
        post :add_choice
      end
    end
    resources :xhtmls
    resources :open_responses
  end

  match "/publications/show_status/:publishable_type/:publishable_id"=> 'publications#show_status', :as => 'publication_show_status'
  match "/publications/add/:publishable_type/:publishable_id"=> 'publications#add_portal', :as => 'publication_add_portal'
  match "/publications/publish/:publishable_type/:publishable_id"=> 'publications#publish', :as => 'publication_publish'
  match "/import" => 'import#import_status', :as => 'import_status', :via => 'get'
  match "/import" => 'import#import', :as => 'import', :via => 'post'

  # These routes didn't work as nested resources
  delete "/embeddable/multiple_choice/:id/remove_choice/:choice_id" => 'embeddable/multiple_choices#remove_choice', :as => 'remove_choice_embeddable_multiple_choice', :constraints => { :id => /\d+/, :choice_id => /\d+/ }
  delete "/video_interactives/:id/remove_source/:source_id" => "video_interactives#remove_source", :as => 'remove_source_video_interactive', :constraints => { :id => /\d+/, :source_id => /\d+/ }
  post "/pages/:id/remove_embeddable/:embeddable_id" => 'interactive_pages#remove_embeddable', :as => 'page_remove_embeddable', :constraints => { :id => /\d+/, :embeddable_id => /\d+/ }
  get "/embeddable/multiple_choice/:id/check" => 'embeddable/multiple_choices#check', :as => 'check_multiple_choice_answer', :constraints => { :id => /\d+/ }
  get "/activities/:activity_id/pages/:id/:response_key" => 'interactive_pages#show', :as => 'page_with_response', :constraints => { :id => /\d+/, :activity_id => /\d+/, :response_key => /[-\w]{36}/ }
  get "/activities/:activity_id/summary/:response_key" => 'lightweight_activities#summary', :as => 'summary_with_response', :constraints => { :activity_id => /\d+/, :response_key => /[-\w]{36}/ }
  get "/activities/:activity_id/resubmit_answers/:response_key" => 'lightweight_activities#resubmit_answers', :as => 'resubmit_answers_for_run', :constraints => { :activity_id => /\d+/, :response_key => /[-\w]{36}/ }
  get "/activities/:activity_id/:response_key" => 'lightweight_activities#show', :as => 'activity_with_response', :constraints => { :activity_id => /\d+/, :response_key => /[-\w]{36}/ }
  get "/runs/dirty" => 'runs#dirty', :as => 'dirty_runs'
  get "/runs/details" => 'runs#details', :as => 'run_details'
  match "/runs/fix_broken_portal_runs/:run_id" => 'runs#fix_broken_portal_runs', :as => 'fix_broken_portal_runs'
  match "/runs/run_info/:run_id" => 'runs#run_info', :as => 'run_info'
  match "test_mail" => 'application#test_mail', :as => 'test_mail'
  match "test_exception" => 'application#test_error', :as => 'test_exception'
  match "test_error" => 'application#test_error', :as => 'test_error'

  # Simple image proxy used by Drawing Tool.
  match "/image-proxy" => 'image_proxy#get'
  match "/home/bad_browser" => "home#bad_browser"

  # Web interface to show the delayed jobs for admins
  # unfortunately this route has caused other route constraints to stop working?
  match "/delayed_job" => DelayedJobWeb, :anchor => false, :via => [:get, :post], :constraints => lambda { |request|
    warden = request.env['warden']
    warden.user && warden.user.admin?
  }
end
