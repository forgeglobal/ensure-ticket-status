class TicketSystemQuery
  JIRA = "jira"
  PIVOTAL = "pivotal"

  def find_ticket_system(ticket)
    ticket_system = TicketSystemQuery::JIRA
    if alternative_team_ticket_system_map.key?(ticket.team_segment)
      team_ticket_system = alternative_team_ticket_system_map[ticket.team_segment] 
      if !team_ticket_system.nil? && team_ticket_system != ""
        ticket_system = team_ticket_system
      end
    end

    ticket_system
  end

  def find_project_id(ticket)
    project_id = nil
    if team_project_id_map.key?(ticket.team_segment)
      team_project_id = team_project_id_map[ticket.team_segment] 
      if !team_project_id.nil? && team_project_id != ""
        project_id = team_project_id
      end
    end

    project_id
  end

  private

  def alternative_team_ticket_system_map 
    @alternative_team_ticket_system_map ||= JSON.parse(ENV["INPUT_TEAM_TO_PROJECT_SYSTEM"])
  end

  def team_project_id_map
    @team_project_id_map ||= JSON.parse(ENV["INPUT_TEAM_TO_PROJECT_ID"])
  end
end
