module Api
  module V1
    class CampaignsController < ApplicationController
      before_filter :restrict_access

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

      private

      def restrict_access
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end
      
    end
  end
end