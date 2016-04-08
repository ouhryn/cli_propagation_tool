require 'octokit'
require 'pry'

class GitPropagation
  DEFAULT_REPO = "coupa/coupa_development"

  attr_accessor :client
  def initialize
  	@client = Octokit::Client.new(:access_token => ENV['CLI_PROPAGATION_TOOL'])
  end

  def create_pr(test_hash)
  	created_pull_requests = []
  	test_hash[:branches].keys.each do |head_branch|
  		pr_hash = {}
  		base_branch = test_hash[:branches][head_branch][:base_branch]
  		title = test_hash[:title]
  		description = test_hash[:description]
  		reviewers = test_hash[:reviewers]
  		jira_main_link = test_hash[:branches][head_branch][:jira_main_link]
  		jira_propagation_link = test_hash[:branches][head_branch][:jira_propagation_link]

  		body = formate_body(description, reviewers, jira_main_link, jira_propagation_link)
  		created_pr = @client.create_pull_request(DEFAULT_REPO, base_branch, head_branch, title, body)

  		pr_hash[base_branch] = created_pr["html_url"]
  		created_pull_requests << pr_hash
  	end

  	created_pull_requests
  end

  private
  	def formate_body(description, reviewers, jira_main_link, jira_propagation_link)
  		reviewers_text = reviewers.map{|reviewer| "- [ ] @#{reviewer}"}.join("\n")
  		reviewers_text << "\n"
  		<<-TEXT
## JIRA
Jira main ticket: #{jira_main_link}
Jira propagation ticket: #{jira_propagation_link}
## Code reviewers
#{reviewers_text}
## Description
#{description}
TEXT
  	end
end

# test_hash = {
# 	branches: {
# 	  "014_release_test_cli_propagation" => {
# 	  	jira_main_link: "http://jira.com",
# 	  	jira_propagation_link: "http://jira.com",
# 	  	base_branch: '014_release',
# 	  },
# 	},
#   reviewers: ['dlandberg', 'dlandberg'],
#   title: 'title',
#   description: 'description'
# }

# git = GitPropagation.new
# hash = git.create_pr(test_hash)
# puts hash
