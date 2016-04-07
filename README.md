# cli_propagation_tool
cli propagation tool

## Prerequisites
- Access to JIRA projects
- Access to the code base
- Clone cli_propagation_tool repository into a directory (```git clone https://github.com/coupa/...```) - optional
- Ruby (& related gems as specified in ```jira_propagations.rb```)
  - gem install jira-ruby (0.1.17)  (note: If you already have this gem installed, do a ```gem update jira-ruby```)
  - gem install highline

##Setup
- Create/modify the file, ```.jlogin``` and add two lines
  - JIRA username
  - JIRA password

