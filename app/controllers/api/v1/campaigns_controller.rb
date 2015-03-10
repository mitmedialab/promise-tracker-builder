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
          end.select { |c| !c.draft? }
          render 'index', formats: [:json]
        elsif params[:user_id]
          api_key = ApiKey.find_by(access_token: token_and_options(request)[0])
          user = User.where(
            api_client_name: api_key.client_name,
            api_client_user_id: params[:user_id]).first

          if user
            @campaigns = user.campaigns
            render 'index', formats: [:json]
          else
            @error_code = 23
            @error_message = 'User not found'
            render 'api/v1/error', format: :json, status: 404
          end
        else
          @campaigns = Campaign.includes(:tags).where.not(status: 'draft')
          render 'index', formats: [:json]
        end
      end

      def show
        @campaign = Campaign.includes(:tags, survey: :inputs).find_by_id(params[:id])
        @user = User.where(api_client_user_id: params[:user_id].to_i).first
        user_id = @user ? @user.id : nil

        if @campaign
          if @campaign.status == 'draft' && @campaign.user_id != user_id
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
          end

          campaign.user_id = user.id
          campaign.save(validate: false)
          render json: {
            status: "success",
            payload: {
              redirect_link: "#{request.url.split("api").first}api/v1/users/sign_in?user_id=#{user.api_client_user_id}&username=#{params[:username]}&campaign_id=#{campaign.id}&token=#{api_key}&locale=pt-BR"
            }
          }.to_json
        else
          @error_code = 22
          @error_message = 'User id and username required'
          render 'api/v1/error', formats: [:json], status: 401
        end
      end
    end
  end
end