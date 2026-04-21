class AddCurrentRailsVersionAndPlatformsToLockfileChecks < ActiveRecord::Migration[8.0]
  def change
    add_column :lockfile_checks, :current_rails_version, :string
    add_column :lockfile_checks, :platforms, :string, array: true, default: [], null: false
  end
end
