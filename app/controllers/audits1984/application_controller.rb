module Audits1984
  class ApplicationController < Audits1984.base_controller_class.constantize
    ActionController::Base::MODULES.each do |mod|
      include mod unless self < mod
    end

    rescue_from ActiveRecord::RecordNotFound do |exception|
      respond_to do |format|
        format.html { raise exception }
        format.json { render json: { error: "Not found" }, status: :not_found }
      end
    end

    rescue_from ActiveRecord::RecordInvalid do |exception|
      respond_to do |format|
        format.html { raise exception }
        format.json { render json: { error: "Validation failed", messages: exception.record.errors.full_messages }, status: :unprocessable_entity }
      end
    end

    before_action :authenticate_auditor

    layout "audits1984/application"

    helper Audits1984::ApplicationHelper unless self < Audits1984::ApplicationHelper
    helper Importmap::ImportmapTagsHelper unless self < Importmap::ImportmapTagsHelper

    private
      def authenticate_auditor
        unless respond_to?(:find_current_auditor, true)
          raise NotImplementedError, "Base controller class '#{Audits1984.base_controller_class}' must implement \#find_current_auditor'"
        end

        unless Current.auditor = (find_current_auditor || auditor_from_bearer_token)
          head :forbidden
        end
      end

      # Parse the Authorization header for a Bearer token and return the associated auditor.
      # Returns nil if no valid token is present. This method is available for use by the
      # application controller class to integrate bearer token authentication into its own auth
      # flow if necessary.
      def auditor_from_bearer_token
        authenticate_with_http_token do |token, _options|
          AuditorToken.find_by_token(token)&.auditor
        end
      end
  end
end
