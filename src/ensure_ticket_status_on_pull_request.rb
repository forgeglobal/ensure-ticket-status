require 'json'

require_relative 'api_credentials'
require_relative 'ticket'
require_relative 'ticket_system_query'
require_relative 'ticket_extractor'

def pivotal_story_endpoint(project_id, story_id) 
  "https://www.pivotaltracker.com/services/v5/projects/#{project_id}/stories/#{story_id}"
end

VALID_PIVOTAL_STATUSES = ["accepted"].freeze
def verify_pivotal_story(story_json, ticket) 
  # Missing stories are not permissible, ensure accepted state.
  story_state = story_json.dig("current_state")
  story_missing = story_state.nil?
  story_accepted = VALID_PIVOTAL_STATUSES.include?(story_state&.downcase)

  raise StandardError.new("Story #{ticket.raw_ticket_id} could not be found in #{TicketSystemQuery::PIVOTAL}.") if story_missing
  raise StandardError.new("Story #{ticket.raw_ticket_id} is in state '#{story_state&.downcase}', which is not in acceptable state(s) (#{VALID_JIRA_STATUSES}).") if !story_accepted
end

def jira_ticket_endpoint(ticket_id) 
  "https://forgeglobal.atlassian.net/rest/api/2/issue/#{ticket_id}"
end

VALID_JIRA_STATUSES = ["accepted", "closed", "delivered"].freeze
def verify_jira_ticket(ticket_json, ticket) 
  # Missing tickets are not permissible, ensure accepted status.
  ticket_status = ticket_json.dig("fields", "status", "name")
  ticket_missing = ticket_status.nil?
  ticket_accepted = VALID_JIRA_STATUSES.include?(ticket_status&.downcase)

  raise StandardError.new("Ticket #{ticket.raw_ticket_id} could not be found in #{TicketSystemQuery::JIRA}.") if ticket_missing
  raise StandardError.new("Ticket #{ticket.raw_ticket_id} is in status '#{ticket_status&.downcase}', which is not in acceptable status(es) (#{VALID_JIRA_STATUSES}).") if !ticket_accepted
end

def dispatch_ticket_request(ticket) 
  case ticket.ticket_system
  when TicketSystemQuery::PIVOTAL
    username, token = ApiCredentials::ticket_system_creds[ticket.ticket_system]
    url = pivotal_story_endpoint(ticket.project_id, ticket.id_segment)
    puts "curl -s -X GET -H \"X-TrackerToken: #{token}\" -H \"Content-Type: application/json\" #{url}"
    resp = `curl -s -X GET -H "X-TrackerToken: #{token}" -H "Content-Type: application/json" #{url}`
    json_resp = JSON.parse(resp)
    verify_pivotal_story(json_resp, ticket)
  when TicketSystemQuery::JIRA
    username, token = ApiCredentials::ticket_system_creds[ticket.ticket_system]
    url = jira_ticket_endpoint(ticket.raw_ticket_id)
    puts "curl -s -u #{username}:#{token} -X GET -H \"Content-Type: application/json\" #{url}"
    resp = `curl -s -u #{username}:#{token} -X GET -H "Content-Type: application/json" #{url}`
    json_resp = JSON.parse(resp)
    verify_jira_ticket(json_resp, ticket)
  else
    raise StandardError.new("Unrecognized ticket system for ticket #{ticket.raw_ticket_id}")
  end
end

# --- main ---

compare_branch = ENV["INPUT_PULL_REQUEST_COMPARE_BRANCH_NAME"]
base_branch = ENV["INPUT_PULL_REQUEST_BASE_BRANCH_NAME"]

ticket_extractor = TicketExtractor.new
ticket_ids = ticket_extractor.extract_ticket_ids_from_commit_diff(base_branch, compare_branch) + 
                ticket_extractor.extract_ticket_ids_from_branch_name(compare_branch)

unique_ticket_ids = ticket_ids.flatten.uniq

ticket_system = TicketSystemQuery.new
maybe_validation_errors = unique_ticket_ids.map {|ticket_id| 
  validation_error = nil
  begin
    ticket = Ticket.new(ticket_system, ticket_id)
    dispatch_ticket_request(ticket)
    puts "Ticket #{ticket_id} passed all ticket checks."
  rescue StandardError => err
    validation_error = err
    puts "Ticket #{ticket_id} failed some ticket checks: #{err.message}"
  end

  validation_error
}

validation_errors = maybe_validation_errors.select{ |maybe_err| !maybe_err.nil? }

if validation_errors.empty?
  puts "All ticket(s) in #{unique_ticket_ids} passed validation."
else
  error_output = validation_errors.map { |err| err.message }.join("\n")

  raise StandardError.new "Some ticket(s) in #{unique_ticket_ids} failed validation: \n#{error_output}"
end
