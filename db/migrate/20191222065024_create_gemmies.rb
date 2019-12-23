class CreateGemmies < ActiveRecord::Migration[6.0]
  def change
    create_table :gemmies do |t|
      t.string :name, index: { unique: true }
      t.text :versions, array: true, default: [], null: false
      t.timestamps
    end
  end
end
