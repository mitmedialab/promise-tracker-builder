PromiseTracker::Application.routes.draw do
  root to: 'forms#new'

  resources :forms do
    resources :inputs
  end
end
