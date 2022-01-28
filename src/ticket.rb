class Ticket 
  attr_accessor :raw_ticket_id, :team_segment, :id_segment, :ticket_system, :project_id

  def initialize(ticket_system_query, ticket_id)
    @raw_ticket_id = ticket_id
    @team_segment, @id_segment = extract_ticket_team_and_numeric_segments(ticket_id)
    @ticket_system = ticket_system_query.find_ticket_system(self)
    @project_id = ticket_system_query.find_project_id(self)
  end

  private 

  def extract_ticket_team_and_numeric_segments(ticket_id) 
    last_dash = ticket_id.rindex("-")
    if last_dash.nil?
      raise StandardError.new("Ticket format failed to parse '#{ticket_id}'. Could not locate a '-' to split.")
    end
    team_segment = ticket_id[0..last_dash-1].upcase
    numeric_segment = ticket_id[last_dash+1..ticket_id.length].upcase

    [team_segment, numeric_segment]
  end
end