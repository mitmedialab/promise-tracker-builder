PromiseTracker::Application.routes.draw do
  get "home/index"
  devise_for :users
  root to: 'home#index'

  resources :users
  resources :forms do
    resources :inputs
  end
end
