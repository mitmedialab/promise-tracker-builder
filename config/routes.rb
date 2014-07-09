PromiseTracker::Application.routes.draw do
  devise_for :users
  root to: 'home#index'

  resources :users
  resources :surveys do
    resources :inputs
  end
end
