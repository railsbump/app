class CreateRailsReleases < ActiveRecord::Migration[6.0]
  def change
    create_table :rails_releases do |t|
      t.string :version, index: { unique: true }
      t.timestamps
    end
  end
end
