PromiseTracker::Application.routes.draw do
  devise_for :users
  root to: 'home#index'

  get '/surveys/:id/preview', to: 'surveys#preview', as: 'preview_survey'
  get '/surveys/:id/launch', to: 'surveys#launch', as: 'launch_survey'

  resources :users
  resources :surveys do
    resources :inputs
  end
end
