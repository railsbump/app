class CreateRubygems < ActiveRecord::Migration
  def change
    create_table :rubygems do |t|
      t.string :name, null: false
      t.string :status, null: false
      t.text :notes

      t.timestamps
    end

    add_index :rubygems, :name, unique: true
  end
end
