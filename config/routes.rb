LightweightStandalone::Application.routes.draw do
  namespace :admin do
    resources :users
  end

  devise_for :users

  root :to => 'lightweight_activities#index'

  resources :activities, :controller => 'lightweight_activities', :constraints => { :id => /\d+/ } do
    member do
      get 'reorder_pages'
      get 'summary'
    end
    resources :pages, :controller => 'interactive_pages', :constraints => { :id => /\d+/ } do
      member do
        get 'reorder_embeddables'
        post 'add_embeddable'
        get 'move_up', :controller => 'lightweight_activities'
        get 'move_down', :controller => 'lightweight_activities'
      end
    end
    resources :activity_responses, :only => [:index, :show, :update], :constraints => { :id => /\w{16}/, :activity_id => /\d+/ }
  end
  
  # These don't need index or show pages - though there might be something to be said for an
  # index .xml file as a feed for select menus - but they need create-update-delete.
  resources :mw_interactives, :controller => 'mw_interactives', :constraints => { :id => /\d+/ }, :except => :show

  # This is so we can build the InteractiveItem at the same time as the Interactive
  resources :pages, :controller => 'interactive_pages', :constraints => { :id => /\d+/ }, :except => :create do
    resources :mw_interactives, :controller => 'mw_interactives', :constraints => { :id => /\d+/ }, :except => :show
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

  # These routes didn't work as nested resources
  delete "/embeddable/multiple_choice/:id/remove_choice/:choice_id" => 'embeddable/multiple_choices#remove_choice', :as => 'remove_choice_embeddable_multiple_choice', :constraints => { :id => /\d+/, :choice_id => /\d+/ }
  post "/pages/:id/remove_embeddable/:embeddable_id" => 'interactive_pages#remove_embeddable', :as => 'page_remove_embeddable', :constraints => { :id => /\d+/, :embeddable_id => /\d+/ }
  get "/embeddable/multiple_choice/:id/check" => 'embeddable/multiple_choices#check', :as => 'check_multiple_choice_answer', :constraints => { :id => /\d+/ }
  get "/activities/:activity_id/pages/:id/:response_key" => 'interactive_pages#show', :as => 'page_with_response', :constraints => { :id => /\d+/, :activity_id => /\d+/, :response_key => /\w{16}/ }
  get "/activities/:activity_id/summary/:response_key" => 'lightweight_activities#summary', :as => 'summary_with_response', :constraints => { :activity_id => /\d+/, :response_key => /\w{16}/ }
end
