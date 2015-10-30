class AddStatusRails5ToRubygems < ActiveRecord::Migration
  def change
    add_column :rubygems, :status_rails5, :string, default: "unknown", null: false
  end
end
