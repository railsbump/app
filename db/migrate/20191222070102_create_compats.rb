class CreateCompats < ActiveRecord::Migration[6.0]
  def change
    create_table :compats do |t|
      t.json :dependencies
      t.string :dependencies_key, :status_determined_by
      t.integer :status
      t.datetime :checked_at
      t.references :rails_release
      t.timestamps
    end

    add_index :compats, %i(dependencies_key rails_release_id), unique: true
  end
end
