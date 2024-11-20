require_dependency "audits1984/application_controller"

module Audits1984
  class FilteredSessionsController < ApplicationController
    def update
      session[:filtered_sessions] = Audits1984::FilteredSessions.new(filtered_sessions_param).to_h
      redirect_to sessions_path
    end

    private
      def filtered_sessions_param
        params.require(:filtered_sessions).permit(:sensitive_only, :from_date, :to_date, :pending_only)
      end
  end
end
