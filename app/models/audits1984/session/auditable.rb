module Audits1984::Session::Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audits, dependent: :destroy, class_name: "Audits1984::Audit"

    scope :sensitive, -> { joins(:sensitive_accesses) }
    scope :reviewed, -> { joins(:audits) }
    scope :approved, -> { reviewed.where("audits.status": :approved) }
    scope :flagged, -> { reviewed.where("audits.status": :flagged) }
    scope :pending, -> { where.not(id: reviewed) }
  end
end
