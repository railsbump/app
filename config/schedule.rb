job_type :rollbar_runner, "cd :path && :environment_variable=:environment bundle exec rollbar-rails-runner :task --silent :output"

every :hour do
  rollbar_runner 'DeleteOldGitBranches.call'
end
