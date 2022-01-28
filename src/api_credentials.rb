
class ApiCredentials
  def self.ticket_system_creds 
    {
      "jira" => [ENV["NONPROD_JIRA_API_USER"],ENV["NONPROD_JIRA_API_TOKEN"]],
      # Pivotal only requires a token.
      "pivotal" => ["",ENV["NONPROD_PIVOTAL_API_TOKEN"]],
    }
  end
end