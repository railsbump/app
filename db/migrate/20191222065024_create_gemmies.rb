# frozen_string_literal: true

class CreateGemmies < ActiveRecord::Migration[6.0]
  def change
    create_table :gemmies do |t|
      t.string :name, index: { unique: true }
      t.jsonb :dependencies_and_versions, default: {}
      t.text :compat_ids, array: true, default: [], null: false
      t.timestamps
    end
  end
end
