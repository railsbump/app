class CreateCompats < ActiveRecord::Migration[6.0]
  def change
    create_table :compats do |t|
      t.jsonb :dependencies
      t.string :dependencies_key
      t.string :status_determined_by
      t.integer :status
      t.datetime :checked_at
      t.references :rails_release, foreign_key: true
      t.timestamps
    end

    add_index :compats, [:dependencies_key, :rails_release_id], unique: true
  end
end
