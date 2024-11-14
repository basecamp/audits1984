module Audits1984
  class ApplicationController < Audits1984.base_controller_class.constantize
    ActionController::Base::MODULES.each do |mod|
      include mod unless self < mod
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

        unless Current.auditor = find_current_auditor
          head :forbidden
        end
      end
  end
end
