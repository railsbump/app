web: bin/rails assets:precompile && bundle exec puma -C config/puma.rb
worker: jemalloc.sh bundle exec sidekiq -c ${SIDEKIQ_CONCURRENCY:-2}
release: bin/rails db:migrate
