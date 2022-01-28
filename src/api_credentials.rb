require_relative "ticket_system_query"

class ApiCredentials
  def self.ticket_system_creds 
    {
      TicketSystemQuery::JIRA => [ENV["NONPROD_JIRA_API_USER"],ENV["NONPROD_JIRA_API_TOKEN"]],
      # Pivotal only requires a token.
      TicketSystemQuery::PIVOTAL => ["",ENV["NONPROD_PIVOTAL_API_TOKEN"]],
    }
  end
end