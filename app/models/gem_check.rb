class GemCheck < ApplicationRecord
  belongs_to :lockfile_check

  RUBYGEMS_SOURCE = "https://rubygems.org/"

  validates :gem_name, presence: true
  validates :status, inclusion: { in: %w[pending complete] }
  validates :result, inclusion: { in: %w[compatible upgrade_needed incompatible skipped] }, allow_nil: true

  def resolvable?
    source == RUBYGEMS_SOURCE && locked_version.present?
  end

  def check!
    resolve(Checks::GemResolver.new(self).call)
  end

  def resolve(result)
    return update!(status: "complete", result: "incompatible", error_message: result.error&.truncate(1000)) unless result.compatible?

    resolved_version = result.resolved_version(gem_name)
    if resolved_version && Gem::Version.new(resolved_version) > Gem::Version.new(locked_version)
      return update!(status: "complete", result: "upgrade_needed", earliest_compatible_version: resolved_version)
    end

    update!(status: "complete", result: "compatible")
  end
end
