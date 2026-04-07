class CreateLockfileChecksAndGemChecks < ActiveRecord::Migration[8.0]
  def change
    create_table :lockfile_checks do |t|
      t.belongs_to :lockfile, null: false, foreign_key: true
      t.belongs_to :rails_release, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :ruby_version
      t.string :rubygems_version
      t.string :bundler_version
      t.timestamps
    end

    add_index :lockfile_checks, [:lockfile_id, :rails_release_id], unique: true

    create_table :gem_checks do |t|
      t.belongs_to :lockfile_check, null: false, foreign_key: true
      t.string :gem_name, null: false
      t.string :locked_version
      t.string :source
      t.string :status, null: false, default: "pending"
      t.string :result
      t.string :earliest_compatible_version
      t.text :error_message
      t.timestamps
    end

    add_index :gem_checks, [:lockfile_check_id, :gem_name], unique: true
  end
end
