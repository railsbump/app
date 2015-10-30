class AddNotesRails5ToRubygems < ActiveRecord::Migration
  def change
    add_column :rubygems, :notes_rails5, :string
  end
end
