web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 2
release: rake assets:clobber && rails assets:precompile
