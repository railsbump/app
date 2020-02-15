class CreateGemmies < ActiveRecord::Migration[6.0]
  def change
    create_table :gemmies do |t|
      t.string :name, index: { unique: true }
      t.jsonb :dependencies_and_versions, default: {}
      t.timestamps
    end
  end
end
