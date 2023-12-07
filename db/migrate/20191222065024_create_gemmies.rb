class CreateGemmies < ActiveRecord::Migration[6.0]
  def change
    create_table :gemmies do |t|
      t.string :name, index: { unique: true }
      t.json :dependencies_and_versions, default: {}
      t.text :compat_ids, array: true, default: [], null: false
      t.check_constraint "JSON_TYPE(compat_ids) = 'array'", name: "gemmy_compat_ids_is_array"
      t.timestamps
    end
  end
end
