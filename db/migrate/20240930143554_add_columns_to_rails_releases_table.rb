class AddColumnsToRailsReleasesTable < ActiveRecord::Migration[7.1]
  def change
    add_column :rails_releases, :minimum_ruby_version, :string
    add_column :rails_releases, :minimum_bundler_version, :string
    add_column :rails_releases, :minimum_rubygems_version, :string
    add_column :rails_releases, :maximum_ruby_version, :string
    add_column :rails_releases, :maximum_bundler_version, :string
    add_column :rails_releases, :maximum_rubygems_version, :string
  end
end
