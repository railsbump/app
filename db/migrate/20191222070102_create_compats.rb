class CreateCompats < ActiveRecord::Migration[6.0]
  def change
    create_table :compats do |t|
      t.string :version
      t.boolean :compatible
      t.datetime :checked_at
      t.references :gemmy
      t.references :rails_release
      t.timestamps
    end
  end
end
