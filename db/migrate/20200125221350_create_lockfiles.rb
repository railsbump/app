class CreateLockfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :lockfiles do |t|
      t.text :content
      t.string :slug, index: { unique: true }
      t.timestamps
    end

    enable_extension 'pgcrypto' # Add this line to enable UUID generation

    # change_column :lockfiles, :id, :uuid, default: 'gen_random_uuid()', null: false # Change the primary key column to UUID
  end
end
