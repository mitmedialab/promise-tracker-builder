module Api
  module V1
    class CampaignsController < ApplicationController
      # before_filter :restrict_access

      def index
        if params[:tags]
          @campaigns = params[:tags].map do |tag|
            Tag.find_by(label: tag).campaigns
          end.reduce do |a, b|
            a || b
          end
        else
          @campaigns = Campaign.all
        end

        render json: @campaigns
      end

      def show
        @survey = Survey.find(params[:id])
        render json: { survey: @survey, inputs: @survey.inputs, campaign: @survey.campaign }
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