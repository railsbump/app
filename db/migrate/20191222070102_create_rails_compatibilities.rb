class CreateRailsCompatibilities < ActiveRecord::Migration[6.0]
  def change
    create_table :rails_compatibilities do |t|
      t.string :version
      t.boolean :compatible
      t.references :gemmy
      t.references :rails_release
    end
  end
end
