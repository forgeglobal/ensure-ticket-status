require_relative "ticket_system_query"

class ApiCredentials
  def self.ticket_system_creds 
    {
      TicketSystemQuery::JIRA => [ENV["INPUT_JIRA_API_USER"],ENV["INPUT_JIRA_API_TOKEN"]],
      # Pivotal only requires a token.
      TicketSystemQuery::PIVOTAL => ["",ENV["INPUT_PIVOTAL_API_TOKEN"]],
    }
  end
end