PromiseTracker::Application.routes.draw do
  devise_for :users
  root to: 'home#index'

  get '/surveys/:id/preview', to: 'surveys#preview', as: 'preview_survey'
  get '/surveys/:id/launch', to: 'surveys#launch', as: 'launch_survey'
  get '/surveys/:id/activate', to: 'surveys#activate', as: 'activate_survey'
  get '/surveys/:id/close', to: 'surveys#close', as: 'close_survey'
  get '/surveys/:id/clone', to: 'surveys#clone', as: 'clone_survey'

  resources :users
  resources :surveys do
    resources :inputs
  end
end
