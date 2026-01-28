require_dependency "audits1984/application_controller"

module Audits1984
  class SessionsController < ApplicationController
    include FilteredSessionsScoped

    def index
      @sessions = @filtered_sessions.all.includes(:user, :audits, :sensitive_accesses)
    end

    def show
      @session = Console1984::Session
        .includes(:user, :sensitive_accesses, commands: :sensitive_access, audits: :auditor)
        .find(params[:id])

      if request.format.html?
        @audit = @session.audits.find_by(auditor: Current.auditor) || @session.audits.build(auditor: Current.auditor)
      end
    end
  end
end
