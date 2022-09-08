# frozen_string_literal: true

class CreateCompats < ActiveRecord::Migration[6.0]
  def change
    create_table :compats do |t|
      t.jsonb :dependencies
      t.uuid :dependencies_key
      t.string :status_determined_by
      t.integer :status
      t.datetime :checked_at
      t.references :rails_release
      t.timestamps
    end

    add_index :compats, %i(dependencies_key rails_release_id), unique: true
  end
end
