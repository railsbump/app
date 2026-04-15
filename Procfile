web: bin/rails assets:precompile && bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c ${SIDEKIQ_CONCURRENCY:-2}
release: bin/rails db:migrate assets:precompile
