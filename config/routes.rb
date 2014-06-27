PromiseTracker::Application.routes.draw do
  resources :forms
  root to: 'forms#new'
end
