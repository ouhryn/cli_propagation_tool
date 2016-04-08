require 'highline'
require 'git'

module Propagator
  class << self

    def params_to_create_propagations user_input
      return user_input.jira_ticket_key, user_data.target_branch_names
    end


    def params_to_create_prs user_data, jira_propagation_result
      result = {:branches => {}}
      jira_propagation_result.each do |pair|
        propagation = OpenStruct.new pair



      end
    end

    def propagate user_data, jira_client, github_client

      jira_propagation_result = jira_client.create_jira_subtasks *params_to_create_propagations(user_input)
      
      propagation_tasks_to_pr_ids = github_client.create_prs input_data.jira_issue_key, jira_propagation_subtask_keys, input_data.target_branch_names, input_data.reviewer_lvl_1, input_data.reviewer_lvl_2, input_data.risk_level, input_data.description

      jira_client.populate_pr_links_to_propagation_tasks

    end
  end
end






module Propagator
  class CLI

    def cli
      @cli ||= ::HighLine.new
    end

    def jira_ticket_key
      cli.ask('Set jira ticket key:')
    end
    
    def target_branch_names
      cli.ask('Please Specify target branches(comma separated list):', lambda {|raw| raw.split(/,\s*/) })
    end

    def reviewer_lvl_1
      cli.ask('Please Specify 1st level reviewer:')
    end

    def reviewer_lvl_2
      puts 'Choose 2nd level reviewer:'
      cli.choose('Eddy Kim', 'Brian Farr')
    end

    def risk_level
      puts 'Choose risk level'
      cli.choose(1,2,3,4,5)
    end

    def description
      cli.ask('Specify description:')
    end

    def poll_user
      OpenStruct.new({
        :jira_ticket_key => jira_ticket_key,
        :target_branche_names => target_branch_names,
        :reviewer_lvl_1 => reviewer_lvl_1,
        :reviewer_lvl_2 => reviewer_lvl_2,
        :risk_level => risk_level,
        :description => description
      })
    end
  end
end

