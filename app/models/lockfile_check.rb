class LockfileCheck < ApplicationRecord
  belongs_to :lockfile
  belongs_to :rails_release
  has_many :gem_checks, dependent: :destroy

  enum :status, { pending: "pending", complete: "complete", failed: "failed" }, validate: true

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

    now  = Time.current
    rows = lockfile.gems.map do |gem|
      if gem.resolvable?
        { lockfile_check_id: lockfile_check.id, gem_name: gem.name, locked_version: gem.version, source: gem.source&.to_s, status: "pending",  result: nil,       created_at: now, updated_at: now }
      else
        { lockfile_check_id: lockfile_check.id, gem_name: gem.name, locked_version: gem.version, source: gem.source&.to_s, status: "complete", result: "skipped", created_at: now, updated_at: now }
      end
    end

    # insert_all bypasses AR validations and callbacks for performance (N→1 INSERT).
    # If GemCheck gains a before_create callback or non-DB-level validation, add it here explicitly.
    # Omitting returning: means inserted IDs are not returned; enqueue_gem_checks does a separate
    # pluck(:id) to get them. Two round-trips, but keeps this method simple.
    GemCheck.insert_all(rows) if rows.any?

    lockfile_check
  end

  def enqueue_gem_checks
    ids = gem_checks.where(status: "pending").pluck(:id)
    if ids.any?
      Checks::ResolveGem.perform_bulk(ids.map { [_1] })
    else
      complete!
    end
  end
end
