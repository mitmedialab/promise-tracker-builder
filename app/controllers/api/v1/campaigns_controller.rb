include ActionController::HttpAuthentication::Token

module Api
  module V1
    class CampaignsController < ApplicationController
      before_filter :restrict_access
      protect_from_forgery with: :null_session

      def index
        if params[:tags]
          campaigns = params[:tags].map do |tag|
            tag = Tag.find_by(label: tag)
            tag.campaigns if tag
          end.reduce do |a, b|
            a || b
          end.select { |c| c.status != 'draft' }
        else
          campaigns = Campaign.all.where.not(status: 'draft')
        end

        response = {
          status: 'success',
          payload: campaigns || []
        }

        render json: response
      end

      def show
        campaign = Campaign.find_by_id(params[:id])
        if campaign
          if campaign.status == 'draft'
            response = {
              status: 'error',
              error_code: 21,
              error_message: 'Campaign has not been published'
            }
          else
            response = {
              status: 'success',
              payload: {
                campaign: campaign,
                survey: campaign.survey,
                responses: campaign.survey.get_responses
              }
            }
          end

          render json: response
        else
          response = {
            status: 'error',
            error_code: 18,
            error_message: 'Campaign not found'
          }

          render json: response
        end
      end

      def create
        api_key = token_and_options(request)[0]
        user = User.find_or_create_api_user(params[:user_id], api_key)
        sign_in(user)

        if current_user
          if params[:campaign_id]
            campaign = Campaign.find(params[:campaign_id]).clone
          else
            campaign = Campaign.create
            campaign.tags = params[:tags] if params[:tags]
            campaign.save(validate: false)
          end

          current_user.campaigns << campaign
          redirect_to setup_campaign_path(campaign)
        end
      end

      private

      def restrict_access
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end
      
    end
  end
end