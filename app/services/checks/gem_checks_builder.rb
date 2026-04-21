# frozen_string_literal: true

module Checks
  # Materializes one GemCheck per top-level dependency of the lockfile
  # (excluding Rails itself and its sub-gems, which are handled by the
  # Rails-version resolution path, not per-gem). Uses a single bulk insert
  # for new rows and skips existing ones so re-runs are idempotent.
  class GemChecksBuilder
    def initialize(lockfile_check, parser)
      @lockfile_check = lockfile_check
      @parser = parser
    end

    def call
      return if gem_names.empty?

      rows = new_rows
      GemCheck.insert_all(rows) if rows.any?

      @lockfile_check.gem_checks
    end

    private

    def gem_names
      @gem_names ||= @parser.dependencies.keys - RailsGems::ALL
    end

    def new_rows
      existing = @lockfile_check.gem_checks.where(gem_name: gem_names).pluck(:gem_name).to_set
      now = Time.current

      (gem_names - existing.to_a).map do |name|
        spec = @parser.spec_for(name)
        {
          lockfile_check_id: @lockfile_check.id,
          gem_name: name,
          locked_version: spec&.version&.to_s,
          source: @parser.source_for(name),
          status: "pending",
          created_at: now,
          updated_at: now
        }
      end
    end
  end
end
