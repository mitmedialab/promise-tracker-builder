PromiseTracker::Application.routes.draw do
  devise_for :users
  root to: 'home#index'
  match ':status', via: [:get, :post], to: 'errors#show', constraints: {status: /\d{3}/ }

  get '/surveys/:id/preview', to: 'surveys#preview', as: 'preview_survey'
  get '/surveys/test', to: 'surveys#test_builder', as: 'test_builder'
  put '/surveys/:id/save-order', to: 'surveys#save_order', as: 'save_order'

  get '/campaigns/:id/goals', to: 'campaigns#goals_wizard', as: 'campaign_goals_wizard'
  get '/campaigns/:id/launch', to: 'campaigns#launch', as: 'launch_campaign'
  get '/campaigns/:id/activate', to: 'campaigns#activate', as: 'activate_campaign'
  get '/campaigns/:id/monitor', to: 'campaigns#monitor', as: 'monitor_campaign'
  get '/campaigns/:id/share', to: 'campaigns#share', as: 'share_campaign'
  get '/campaigns/:id/close', to: 'campaigns#close', as: 'close_campaign'
  post '/campaigns/:id/clone', to: 'campaigns#clone', as: 'clone_campaign'

  post '/inputs/:id/clone', to: 'inputs#clone', as: 'clone_input'

  get '/download', to: 'home#download', as: 'download'

  scope "(:locale)", locale: /en|pt-BR/ do
    resources :users
    resources :campaigns
    resources :surveys do
      resources :inputs
    end
  end

  namespace :api do
    namespace :v1 do
      resources :campaigns, only: [:index, :show]
    end
  end
end
