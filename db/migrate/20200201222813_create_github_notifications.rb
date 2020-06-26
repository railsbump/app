class CreateGithubNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :github_notifications do |t|
      t.jsonb :data
      t.datetime :processed_at
      t.references :compat
      t.timestamps
    end
  end
end
