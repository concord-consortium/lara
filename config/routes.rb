LightweightStandalone::Application.routes.draw do
  # HACK: Seems like these should be nested resources of the offering, but that's not really practical
  # with the engine's URL scheme. Either way, we need to be able to optionally specify an offering ID.
  resources :activities, :controller => 'lightweight_activities', :constraints => { :id => /\d+/ } do
    resources :pages, :controller => 'interactive_pages', :constraints => { :id => /\d+/ } do
      post 'add_embeddable', :on => :member
    end
  end
  
  # These don't need index or show pages - though there might be something to be said for an
  # index .xml file as a feed for select menus - but they need create-update-delete.
  resources :mw_interactives, :controller => 'mw_interactives', :constraints => { :id => /\d+/ }, :except => :show

  # This is so we can build the InteractiveItem at the same time as the Interactive
  resources :pages, :controller => 'interactive_pages', :constraints => { :id => /\d+/ } do
    resources :mw_interactives, :controller => 'mw_interactives', :constraints => { :id => /\d+/ }, :except => :show
  end

  # the in-place editor needed interactive_page_path
  resources :pages, :as => 'interactive_pages', :controller => 'interactive_pages', :constraints => { :id => /\d+/ }, :except => [:new, :create]

  # This route didn't work as a nested resource
  post "/pages/:id/remove_embeddable/:embeddable_id" => 'interactive_pages#remove_embeddable', :as => 'page_remove_embeddable', :constraints => { :id => /\d+/, :embeddable_id => /\d+/ }
end
