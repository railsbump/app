job_type :rollbar_runner, "cd :path && :environment_variable=:environment bundle exec rollbar-rails-runner :task --silent :output"

every 2.minutes do
  rollbar_runner 'Maintenance::CheckSidekiq.call'
end

every 10.minutes do
  rollbar_runner 'Compats::CheckAllUnchecked.call'
end

every :hour do
  rollbar_runner 'Maintenance::CheckGitBranches.call'
  rollbar_runner 'Maintenance::CheckPendingCompats.call'
  rollbar_runner 'Gemmies::UpdateAllCompats.call'
end

every :day do
  rake '-s sitemap:refresh'
end
