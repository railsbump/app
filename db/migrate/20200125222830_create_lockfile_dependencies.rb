# frozen_string_literal: true

class CreateLockfileDependencies < ActiveRecord::Migration[6.0]
  def change
    create_table :lockfile_dependencies, id: false do |t|
      t.references :lockfile
      t.references :gemmy
    end
  end
end
