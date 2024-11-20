module Audits1984
  class FilteredSessions
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :from_date, :date
    attribute :to_date, :date
    attribute :sensitive_only, :boolean
    attribute :pending_only, :boolean

    def self.resume(attributes)
      new attributes&.with_indifferent_access&.slice(*attribute_names)
    end

    def to_h
      attributes.compact.transform_values(&:to_s)
    end

    def all
      sessions = Console1984::Session.order(created_at: :desc, id: :desc)
      sessions = sessions.sensitive if sensitive_only
      sessions = sessions.pending if pending_only
      sessions = sessions.where("console1984_sessions.created_at >= ?", from_date.beginning_of_day) if from_date.present?
      sessions = sessions.where("console1984_sessions.created_at <= ?", to_date.end_of_day) if to_date.present?
      sessions
    end

    def pending_session_after(session)
      all.pending.where("console1984_sessions.created_at < ? OR console1984_sessions.id < ?", session.created_at, session.id).first
    end
  end
end
