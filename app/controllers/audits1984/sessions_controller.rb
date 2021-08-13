require_dependency "audits1984/application_controller"

module Audits1984
  class SessionsController < ApplicationController
    include FilteredSessionsScoped

    def index
      @sessions = @filtered_sessions.all
    end

    def show
      @session = Console1984::Session.find(params[:id])
      @audit = @session.audits.find_by(auditor: Current.auditor) || @session.audits.build(auditor: Current.auditor)
    end
  end
end
