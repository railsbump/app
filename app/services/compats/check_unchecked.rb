module Compats
  class CheckUnchecked < Baseline::Service
    LIMIT = 100

    def call
      check_uniqueness

      count = 0

      RailsRelease
        .latest_major
        .reverse
        .concat(RailsRelease.all)
        .uniq
        .each do |rails_release|

        break unless count < LIMIT

        rails_release
          .compats
          .unchecked
          .limit(LIMIT - count)
          .each do |compat|

          count += 1
          Compats::Check.call compat
        end
      end
    end
  end
end
