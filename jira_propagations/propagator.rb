require 'highline'
require 'git'

require 'jira_popagations'
require '../git_propagations'

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

module Propagator
  class << self

    def params_to_create_propagations user_input
      return user_input.jira_ticket_key, user_data.target_branch_names
    end


    def params_to_create_prs user_data, jira_propagation_result
      result = {:branches => {}}
      jira_propagation_result.each do |pair|
        propagation = OpenStruct.new pair


        result[:branches]["#{pair.target_branch}_#{user_data.jira_ticket_key}".to_sym] = {
          :jira_main_link => "https://coupadev.atlassian.net/browse/#{user_data.jira_ticket_key}",
          :jira_propagation_link => "https://coupadev.atlassian.net/browse/#{pair.sub_ticket_key}",
          :base_branch => pair.target_branch,
          :title => "#{user_data.jira_ticket_key} #{user_data.sub_ticket_key} #{pair.target_branch}"
        }
      end

      result[:description] = user_data.description
      result[:reviewers] = [user_data.reviewer_lvl_1, user_data.reviewer_lvl_2]
      result[:risk_level] = user_data.risk_level
      result

    end

    def params_to_populate_prs_to_subtasks tasks_to_pr_ids
      tasks_to_pr_ids.each_pair.map do |ticket_key, pr_url|
        {:key => ticket_key, :url => pr_url} 
      end
    end

    def propagate user_data, github_client
      jira_client = JiraPropagation.new *params_to_create_propagations(user_input)
      jira_propagation_result = jira.create_jira_sub_task#jira_client.create_jira_subtasks 
      
      propagation_tasks_to_pr_ids = github_client.create_pr *oarams_to_create_prs

      jira_client.update_sub_tasks propagation_tasks_to_pr_ids

    end
  end
end


Propagator.propagate Propagator::CLI.new.poll_user, GitPropagation.new 



