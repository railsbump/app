module RailsReleases
  class ProcessUnprocessed < Services::Base
    CACHE_KEY = 'processed_rails_releases'

    def call
      check_uniqueness on_error: :return

      RailsRelease.find_each do |rails_release|
        return if Compat.unchecked.any?

        next if Redis.current.sismember(CACHE_KEY, rails_release.id)

        Process.call rails_release

        Redis.current.sadd(CACHE_KEY, rails_release.id)
        Redis.current.expire(CACHE_KEY, 1.month)
      end

      Rollbar.error 'All Rails releases processed!'
    end
  end
end
