class Lockfile
  # Pre-flight check on a submitted Gemfile.lock string. Returns a Result with
  # a reason code that callers (controllers, jobs) can branch on without
  # persisting anything. Centralized REASONS table makes adding new
  # rejection cases a one-line change.
  class Inspection
    Result = Data.define(:reason, :lockfile) do
      def message     = REASONS.fetch(reason).fetch(:message)
      def http_status = REASONS.fetch(reason).fetch(:http_status)
      def runnable?   = reason == :runnable
    end

    REASONS = {
      runnable: {
        http_status: :accepted,
        message: nil
      },
      up_to_date: {
        http_status: :ok,
        message: "Your Gemfile.lock is already on the latest known Rails version. There is no upgrade target to check against."
      },
      no_rails_dependency: {
        http_status: :unprocessable_content,
        message: "This Gemfile.lock has no Rails dependency. RailsBump only checks Rails apps."
      },
      invalid_content: {
        http_status: :unprocessable_content,
        message: "Content does not look like a valid Gemfile.lock."
      }
    }.freeze

    def self.call(content)
      new(content).call
    end

    def initialize(content)
      @content = content.to_s.strip
    end

    def call
      return result(:invalid_content) unless valid_content?

      lockfile = Lockfile.new(content: @content)

      return result(:no_rails_dependency) if lockfile.rails_version.blank?
      return result(:up_to_date)          if lockfile.next_rails_release.nil?
      return result(:invalid_content)     if lockfile.invalid?

      result(:runnable, lockfile: lockfile)
    rescue Bundler::LockfileError
      result(:invalid_content)
    end

    private

      def result(reason, lockfile: nil)
        Result.new(reason: reason, lockfile: lockfile)
      end

      def valid_content?
        Lockfile::CONTENT_REGEX.match?(@content)
      end
  end
end
