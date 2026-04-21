# frozen_string_literal: true

module Checks
  # Entry point for the "new check flow". Thin orchestrator:
  #   parse -> build lockfile_check -> materialize gem_checks -> dispatch.
  #
  # Returns a Result so callers can distinguish why no work was scheduled
  # (e.g. :no_rails vs :no_newer_release) instead of reading a bare nil.
  class Creator
    Result = Data.define(:lockfile_check, :reason) do
      def success? = lockfile_check.present?
    end

    def initialize(lockfile)
      @lockfile = lockfile
    end

    def call
      return Result.new(nil, :no_rails) unless parser.rails_version

      lockfile_check = LockfileCheckBuilder.new(@lockfile, parser).call
      return Result.new(nil, :no_newer_release) unless lockfile_check

      GemChecksBuilder.new(lockfile_check, parser).call
      DispatchPendingGemChecks.new(lockfile_check).call

      Result.new(lockfile_check, :ok)
    end

    private

    def parser
      @parser ||= LockfileParser.new(@lockfile.content)
    end
  end
end
