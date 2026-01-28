module Audits1984
  class AuditorTokensController < ApplicationController
    def show
      @auditor_token = current_auditor_token
    end

    def create
      @new_token_plaintext = AuditorToken.generate_for(Current.auditor)
      @auditor_token = current_auditor_token
      render :show, status: :created
    end

    def destroy
      current_auditor_token&.destroy
      redirect_to auditor_token_path
    end

    private
      def current_auditor_token
        AuditorToken.find_by(auditor: Current.auditor)
      end
  end
end
