json.session do
  json.id @session.id
  json.user @session.user&.username
  json.reason @session.reason
  json.created_at @session.created_at.iso8601
  json.sensitive @session.sensitive?

  batches = []
  @session.each_batch_of_commands_grouped_by_sensitive_access do |sensitive_access, commands|
    batches << {
      sensitive: sensitive_access.present?,
      justification: sensitive_access&.justification,
      commands: commands.map { |c| c.statements.chomp }
    }
  end
  json.command_batches batches

  json.audits @session.audits do |audit|
    json.partial! "audits1984/audits/audit", audit: audit, embedded: true
  end
end
