PromiseTracker::Application.routes.draw do
  devise_for :users
  root to: 'home#index'
  match ':status', via: [:get, :post], to: 'errors#show', constraints: {status: /\d{3}/ }

  scope "(:locale)", locale: /en|pt-BR/ do
    resources :users
    resources :campaigns
    resources :surveys, except: [:index] do
      resources :inputs
    end

    get '/surveys/:id/preview', to: 'surveys#preview', as: 'preview_survey'
    get '/surveys/test', to: 'surveys#test_builder', as: 'test_builder'
    put '/surveys/:id/save-order', to: 'surveys#save_order', as: 'save_order'

    get '/campaigns/:id/setup', to: 'campaigns#setup', as: 'setup_campaign'
    get '/campaigns/:id/goals-wizard', to: 'campaigns#goals_wizard', as: 'campaign_goals_wizard'
    get '/campaigns/:id/goals', to: 'campaigns#goals', as: 'campaign_goals'
    get '/campaigns/:id/launch', to: 'campaigns#launch', as: 'launch_campaign'
    get '/campaigns/:id/survey', to: 'campaigns#survey', as: 'campaign_survey'
    get '/campaigns/:id/profile', to: 'campaigns#profile', as: 'campaign_profile'
    get '/campaigns/:id/edit-profile', to: 'campaigns#edit_profile', as: 'edit_campaign_profile'
    get '/campaigns/:id/test', to: 'campaigns#test', as: 'test_campaign'
    get '/campaigns/:id/monitor', to: 'campaigns#monitor', as: 'monitor_campaign'
    get '/campaigns/:id/share', to: 'campaigns#share', as: 'share_campaign'
    get '/campaigns/:id/close', to: 'campaigns#close', as: 'close_campaign'
    get '/campaigns/:id/next', to: 'campaigns#next', as: 'campaign_next'
    post '/campaigns/:id/activate', to: 'campaigns#activate', as: 'activate_campaign'
    post '/campaigns/:id/clone', to: 'campaigns#clone', as: 'clone_campaign'

    post '/inputs/:id/clone', to: 'inputs#clone', as: 'clone_input'

    get '/download', to: 'home#download', as: 'download'
  end

  namespace :api do
    namespace :v1 do
      resources :campaigns, only: [:index, :show, :create]
      post '/users/sign_in', to: 'users#create_new_session', as: 'api_sign_in'
    end
  end
end
