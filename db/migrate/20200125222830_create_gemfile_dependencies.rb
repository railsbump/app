class CreateGemfileDependencies < ActiveRecord::Migration[6.0]
  def change
    create_table :gemfile_dependencies, id: false do |t|
      t.references :gemfile
      t.references :gemmy
    end
  end
end
