web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 2
release: rails assets:precompile && rails dartsass:build
