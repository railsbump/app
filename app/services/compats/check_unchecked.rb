module Compats
  class CheckUnchecked < Baseline::Service
    LIMIT = 100

    def call
      check_uniqueness on_error: :return

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

          next if check_failed?(compat)

          if Date.current > Date.new(2024, 6, 1)
            ReportError.call "remove this!"
          end
          if compat.invalid?
            compats = Compat.where(dependencies: compat.dependencies)
            if compats.size == RailsRelease.count && !compats.include?(compat)
              compat.destroy
              next
            end
          end

          begin
            Compats::Check.call compat
          rescue Compats::Check::Error => error
            ReportError.call error,
              compat_id: compat.id
            check_failed!(compat)
          else
            count += 1
          end
        end
      end
    end

    private

      def check_failed_cache_key(compat)
        [
          :compat_check_failed,
          compat.id
        ].join(":")
      end

      def check_failed?(compat)
        Kredis.redis.exists? \
          check_failed_cache_key(compat)
      end

      def check_failed!(compat)
        Kredis.redis.setex \
          check_failed_cache_key(compat),
          1.hour,
          nil
      end
  end
end
