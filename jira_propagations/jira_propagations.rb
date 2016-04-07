require 'jira'
require 'highline/import'
require 'pp'
require 'pry'

class JiraPropagation
  attr_accessor :options, :new_sub_tickets

  def initialize jira_key, target_branches
    @username, @password = JiraPropagation.read_credentials_from_file
    @options = {
        :username => @username,
        :password => @password,
        :site => "https://coupadev.atlassian.net/",
        :auth_type => :basic,
        :use_ssl => true,
        :context_path => ''
    }
    @jira_key = jira_key
    @target_branches = target_branches
  end

  def update_sub_tasks(sub_ticket_options)
    client = JIRA::Client.new(options)
    parent_jira_sub_ticket_id = ''
    sub_ticket_options.each do |option|
      jira_sub_ticket = client.Issue.find("#{option[:key]}")
      comment = jira_sub_ticket.comments.build
      comment.save!(:body => "PR #{option[:url]}")
      transition = jira_sub_ticket.transitions.build
      transition.save!("transition" => {"id" => 381})
      parent_jira_sub_ticket_id = jira_sub_ticket.parent['id']
    end
    parent_jira_sub_ticket = client.Issue.find("#{parent_jira_sub_ticket_id}")
    if parent_jira_sub_ticket.status.name != "Code Propagation"
      transition = parent_jira_sub_ticket.transitions.build
      transition.save!("transition" => {"id" => 521})
    end
    p "Jira sub tickets were successfully updated"
  end

  def new_sub_ticket_options
    sub_ticket_options = []
    @new_sub_tickets.each do |sub_ticket|
      sub_ticket_options << {sub_ticket_key: sub_ticket.key}
    end
    sub_ticket_options
  end

  def self.read_credentials_from_file
    f = File.open("./.jlogin", "r")
    [f.readline.chomp, f.readline.chomp]
  end

  def create_jira_sub_task
    client = JIRA::Client.new(@options)
    jira_ticket = client.Issue.find("#{@jira_key}")
    jira_project = client.Project.find("#{@jira_key[/\A\w+/]}")

    @new_sub_tickets = @target_branches.map do |target_branch|
      sub_ticket = client.Issue.build
      sub_ticket.save({fields: {parent: {id: "#{jira_ticket.id}"}, project: {id: "#{jira_project.id}"}, summary: "Propagate #{@jira_key} in #{target_branch}", issuetype: {id: "10600"}, description: "", customfield_12905: {'name' => "#{target_branch}"}}})
      sub_ticket.fetch

      transition = sub_ticket.transitions.build
      transition.save!("transition" => {"id" => 4})
      sub_ticket
    end

    if jira_ticket.status.name != "In Progress"
      transition = jira_ticket.transitions.build
      transition.save!("transition" => {"id" => 4})
    end

    @new_sub_tickets
  end
end

jira = JiraPropagation.new("CD-52443", ["014_6_release", "014_7_release"])
jira.create_jira_sub_task
options = jira.new_sub_ticket_options

option_hash = [{key: options[0][:sub_ticket_key], url: "http://www.google.com"}, {key: options[1][:sub_ticket_key], url: "http://www.google.com.ua"}]
jira.update_sub_tasks(option_hash)

