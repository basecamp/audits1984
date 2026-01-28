module Audits1984
  module FilteredSessionsScoped
    extend ActiveSupport::Concern

    included do
      before_action :set_filtered_sessions
    end

    private
      def set_filtered_sessions
        # For JSON requests, read filters from query params; for HTML, use session
        filter_source = request.format.json? ? filter_params_from_query : session[:filtered_sessions]
        @filtered_sessions = Audits1984::FilteredSessions.resume(filter_source)
      end

      def filter_params_from_query
        params.permit(:sensitive_only, :pending_only, :from_date, :to_date).to_h
      end
  end
end
