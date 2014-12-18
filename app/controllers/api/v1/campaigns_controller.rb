include ActionController::HttpAuthentication::Token

module Api
  module V1
    class CampaignsController < ApplicationController
      before_filter :restrict_access
      protect_from_forgery with: :null_session, except: [:create]

      def index
        if params[:tags]
          @campaigns = params[:tags].map do |tag|
            tag = Tag.find_by(label: tag)
            tag.campaigns if tag
          end.reduce do |a, b|
            a || b
          end.select { |c| c.status != 'draft' }
        else
          @campaigns = Campaign.includes(:tags).where.not(status: 'draft')
        end

        render 'index', formats: [:json]
      end

      def show
        @campaign = Campaign.includes(:tags, survey: :inputs).find_by_id(params[:id])

        if @campaign
          if @campaign.status == 'draft'
            @error_code = 21
            @error_message = 'Campaign has not been published'
            render 'api/v1/error', format: :json, status: 401
          else
            render 'show', formats: [:json]
          end
        else
          @error_code = 18
          @error_message = 'Campaign not found'
          render 'api/v1/error', formats: [:json], status: 404
        end
      end

      def create
        api_key = token_and_options(request)[0]

        if params[:user_id] && params[:username]
          user = User.find_or_create_api_user(
            params[:user_id],
            params[:username],
            api_key)
          sign_in(user)

          if params[:campaign_id]
            existing_campaign = Campaign.find_by(id: params[:campaign_id])

            if existing_campaign
              campaign = existing_campaign.clone
            else
              @error_code = 18
              @error_message = 'Campaign not found'
              render 'api/v1/error', format: :json, status: 404 and return
            end
          else
            campaign = Campaign.create
            campaign.tags = params[:tags] if params[:tags]
            campaign.save(validate: false)
          end
          current_user.campaigns << campaign
          redirect_to setup_campaign_path(campaign)
        else
          @error_code = 22
          @error_message = 'User id and username required'
          render 'api/v1/error', formats: [:json], status: 401
        end
      end
    end
  end
end