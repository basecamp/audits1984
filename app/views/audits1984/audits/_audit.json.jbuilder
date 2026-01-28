json.id audit.id
json.status audit.status
json.notes audit.notes
json.auditor_id audit.auditor_id
json.session_id audit.session_id unless local_assigns[:embedded]
json.created_at audit.created_at.iso8601
json.updated_at audit.updated_at.iso8601
