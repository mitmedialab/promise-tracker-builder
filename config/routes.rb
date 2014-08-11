PromiseTracker::Application.routes.draw do
  get "campaigns/new"
  get "campaigns/create"
  get "campaigns/edit"
  get "campaigns/update"
  get "campaigns/destroy"
  devise_for :users
  root to: 'home#index'

  get '/surveys/:id/preview', to: 'surveys#preview', as: 'preview_survey'

  get '/campaigns/:id/launch', to: 'campaigns#launch', as: 'launch_campaign'
  get '/campaigns/:id/activate', to: 'campaigns#activate', as: 'activate_campaign'
  get '/campaigns/:id/close', to: 'campaigns#close', as: 'close_campaign'
  get '/campaigns/:id/clone', to: 'campaigns#clone', as: 'clone_campaign'

  resources :users
  resources :campaigns
  resources :surveys do
    resources :inputs
  end
end
