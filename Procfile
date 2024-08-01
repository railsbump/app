web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 2
release: bin/rails dartsass:build && bin/rails assets:precompile