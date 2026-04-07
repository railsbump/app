web: bin/rails assets:precompile && bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 15
release: bin/rails assets:precompile && bundle exec rake sitemap:create
