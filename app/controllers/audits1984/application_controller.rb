module Audits1984
  class ApplicationController < Audits1984.base_controller_class.constantize
    before_action :authenticate_auditor

    layout "audits1984/application"

    private
      def authenticate_auditor
        unless respond_to?(:find_current_auditor, true)
          raise NotImplementedError, "Base controller class '#{Audits1984.base_controller_class}' must implement \#find_current_auditor'"
        end

        unless Current.auditor = find_current_auditor
          head :forbidden
        end
      end
  end
end
