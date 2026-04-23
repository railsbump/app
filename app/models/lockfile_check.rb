class LockfileCheck < ApplicationRecord
  belongs_to :lockfile
  belongs_to :rails_release
  has_many :gem_checks, dependent: :destroy

  validates :status, inclusion: { in: %w[pending complete failed] }

  def self.create_for!(lockfile:, rails_release:)
    runtime = TargetRuntime.new(lockfile: lockfile, rails_release: rails_release)

    lockfile_check = create_with(
      status: "pending",
      ruby_version: runtime.ruby_version,
      rubygems_version: runtime.rubygems_version,
      bundler_version: runtime.bundler_version
    ).find_or_create_by!(
      lockfile: lockfile,
      rails_release: rails_release
    )

    lockfile.gems.each do |gem|
      GemCheck.create_for!(lockfile_check: lockfile_check, gem: gem)
    end

    lockfile_check
  end

  def enqueue_gem_checks
    gem_checks.where(status: "pending").find_each do |gem_check|
      Checks::ResolveGem.perform_async(gem_check.id)
    end
  end
end
