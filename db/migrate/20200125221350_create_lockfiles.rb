class CreateLockfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :lockfiles do |t|
      t.text :content
      t.string :slug, index: { unique: true }
      t.timestamps
    end
  end
end
