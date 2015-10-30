class RenameNotesToNotesRails4 < ActiveRecord::Migration
  def change
    rename_column :rubygems, :notes, :notes_rails4
  end
end
