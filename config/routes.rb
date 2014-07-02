PromiseTracker::Application.routes.draw do
  devise_for :users
  root to: 'forms#new'

  resources :users
  resources :forms do
    resources :inputs
  end
end
