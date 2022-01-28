require 'json'

class TicketExtractor 
  def extract_ticket_ids_from_commit_diff(base_branch, compare_branch)
    # parse ticket id out of branch
    commits = `git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative origin/#{base_branch}..origin/#{compare_branch}`

    ticket_ids = commits.split("\n").map { |line| 
      line.scan(ticket_id_regex)
    }.flatten.uniq

    ticket_ids
  end

  def extract_ticket_ids_from_branch_name(compare_branch)
    compare_branch.scan(ticket_id_regex)
  end

  private 

  def ticket_id_regex
    @ticket_id_regex ||= ticket_id_regex_init
  end

  def ticket_id_regex_init
    # Regex case invariant on teams for convenience
    teams_regex_segment_upper = teams.map{ |team| Regexp.quote(team.upcase) }.join("|")
    teams_regex_segment_lower = teams.map{ |team| Regexp.quote(team.downcase) }.join("|")
    teams_regex_segment = "#{teams_regex_segment_upper}|#{teams_regex_segment_lower}"
    ticket_id_regex = /(#{teams_regex_segment})\-\d+/

    ticket_id_regex
  end

  def teams 
    @teams ||= teams_from_env
  end

  def teams_from_env 
    teams = JSON.parse(ENV["INPUT_TEAMS"])
    if teams.nil? || teams.empty?
      raise StandardError.new("No teams were provided to search for.")
    end

    teams
  end
end