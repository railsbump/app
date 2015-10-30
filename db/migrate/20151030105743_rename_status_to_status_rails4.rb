class RenameStatusToStatusRails4 < ActiveRecord::Migration
  def change
    rename_column :rubygems, :status, :status_rails4
  end
end
