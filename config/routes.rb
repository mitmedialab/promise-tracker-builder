PromiseTracker::Application.routes.draw do
  get "campaigns/new"
  get "campaigns/create"
  get "campaigns/edit"
  get "campaigns/update"
  get "campaigns/destroy"
  devise_for :users
  root to: 'home#index'

  get '/surveys/:id/preview', to: 'surveys#preview', as: 'preview_survey'
  get '/surveys/test', to: 'surveys#test_builder', as: 'test_builder'

  get '/campaigns/:id/goals', to: 'campaigns#goals_wizard', as: 'campaign_goals_wizard'
  get '/campaigns/:id/launch', to: 'campaigns#launch', as: 'launch_campaign'
  get '/campaigns/:id/activate', to: 'campaigns#activate', as: 'activate_campaign'
  get '/campaigns/:id/monitor', to: 'campaigns#monitor', as: 'monitor_campaign'
  get '/campaigns/:id/share', to: 'campaigns#share', as: 'share_campaign'
  get '/campaigns/:id/close', to: 'campaigns#close', as: 'close_campaign'
  get '/campaigns/:id/clone', to: 'campaigns#clone', as: 'clone_campaign'

  get '/inputs/:id/clone', to: 'inputs#clone', as: 'clone_input'

  scope "(:locale)", locale: /en|pt-BR/ do
    resources :users
    resources :campaigns
    resources :surveys do
      resources :inputs
    end
  end
end
