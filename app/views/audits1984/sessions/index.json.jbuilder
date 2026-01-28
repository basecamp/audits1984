json.sessions @sessions do |session|
  json.id session.id
  json.user session.user&.username
  json.reason session.reason
  json.created_at session.created_at.iso8601
  json.sensitive session.sensitive?
  json.audit_statuses session.audits.map(&:status)
end
