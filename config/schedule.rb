job_type :rollbar_runner, "cd :path && :environment_variable=:environment bundle exec rollbar-rails-runner :task --silent :output"

every 2.minutes do
  rollbar_runner 'Maintenance::CheckSidekiq.call'
end

every :hour do
  rollbar_runner 'CheckGitBranches.call'
end
