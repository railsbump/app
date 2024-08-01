web: bin/rails assets:precompile && bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 2
release: bin/rails assets:precompile
