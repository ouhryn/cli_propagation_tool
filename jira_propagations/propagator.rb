require 'highline'
require 'git'

g = Git.open(Dir.pwd)

p g.branches.local.find(&:current).name

# Basic usage

=begin
answer = cli.choose do |menu|
  menu.prompt = "Please choose your favorite programming language?  "
  menu.choice(:ruby) { cli.say("Good choice!") }
  menu.choices(:python, :perl) { cli.say("Not from around here, are you?") }
end

p answer

answer = cli.choose(:ruby,:python,:perl)

p answer
=end

#choose
#target branches
#1st lvl reviewer
#2nd lvl reviewer
#risk level
#description

module Propagator
  module Git
    class << self
      def client
        @client ||= Git.open(Dir.pwd)
      end
      
      def current_branch_name
        client.branches.local.find(&:current).name 
      end
    end
  end
end

module Propadator
  class InputData
    def initialize cli, git
      @git = git
      @cli = cli
    end

    def github_creds
      #load github creds here
    end

    def jira_creds
      #load jira creds here
    end


    def jira_issue_key
      current_branch_name.split('_').last
    end

    def branches_to_push
      user_input_data.target_branch_names.map do |target_branch_name|
        [target_branch_name, jira_issue_key].join('_')
      end
    end

    def current_branch_name
      @current_branch_name ||= Git.current_branch_name
    end

    def user_input_data
      @pr_data ||= CLI.poll_user
    end

  end
end

module Propagator
  class << self



    def propagate input_data, git_client, jira_client, github_client

      git_client.push_branches input_data.branches_to_push_names

      jira_propagation_subtask_keys = jira_client.create_propagation_subtasks input_data.jira_issue_key, input_data.target_branch_names
      
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
        :target_branche_names => target_branch_names,
        :reviewer_lvl_1 => reviewer_lvl_1,
        :reviewer_lvl_2 => reviewer_lvl_2,
        :risk_level => risk_level,
        :description => description
      })
    end
  end
end

