class ApplicationController < ActionController::Base
  def find_current_auditor
    Auditor.find_or_create_by!(name: "Jorge")
  end
end
