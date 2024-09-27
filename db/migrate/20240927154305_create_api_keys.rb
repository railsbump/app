class CreateAPIKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :api_keys do |t|
      t.string :name
      t.string :key

      t.timestamps
    end

    add_index :api_keys, :name, unique: true
    add_index :api_keys, :key, unique: true
  end
end
