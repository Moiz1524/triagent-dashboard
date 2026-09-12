namespace :github do
  desc "Import security-labeled GitHub issues for every configured company"
  task import_security_issues: :environment do
    PollGithubSecurityIssuesJob.perform_now
  end
end
