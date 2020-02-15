class CreateCompats < ActiveRecord::Migration[6.0]
  def change
    create_table :compats do |t|
      t.jsonb :dependencies
      t.boolean :compatible
      t.datetime :checked_at
      t.references :rails_release
      t.timestamps
    end
  end
end
