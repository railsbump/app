class GemCheck < ApplicationRecord
  belongs_to :lockfile_check

  validates :gem_name, presence: true
  validates :status, inclusion: { in: %w[pending complete] }
  validates :result, inclusion: { in: %w[compatible upgrade_needed incompatible skipped] }, allow_nil: true

  def self.create_for!(lockfile_check:, gem:)
    attributes = { locked_version: gem.version, source: gem.source }

    if gem.resolvable?
      attributes.merge!(status: "pending")
    else
      attributes.merge!(status: "complete", result: "skipped")
    end

    create_with(attributes).find_or_create_by!(lockfile_check: lockfile_check, gem_name: gem.name)
  end

  def perform!
    result = resolver.call

    if result.compatible?
      resolved_version = result.resolved_version(gem_name)

      if resolved_version && Gem::Version.new(resolved_version) > Gem::Version.new(locked_version)
        update!(status: "complete", result: "upgrade_needed", earliest_compatible_version: resolved_version)
      else
        update!(status: "complete", result: "compatible")
      end
    else
      update!(status: "complete", result: "incompatible", error_message: result.error)
    end
  end

  def resolver
    DirectResolver::Subprocess.new(
      rails_version: lockfile_check.rails_release.version.to_s,
      ruby_version: lockfile_check.ruby_version,
      rubygems_version: lockfile_check.rubygems_version,
      bundler_version: lockfile_check.bundler_version,
      dependencies: { gem_name => ">= #{locked_version}" },
      promoter: :earliest
    )
  end
end
