class CreateInaccessibleGemmies < ActiveRecord::Migration[7.1]
  def change
    create_table :inaccessible_gemmies do |t|
      t.text :name
      t.belongs_to :lockfile, null: false, foreign_key: true
      t.timestamps
    end

    add_index :inaccessible_gemmies, [:lockfile_id, :name], unique: true
  end
end
