class CreateGithubNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :github_notifications do |t|
      t.string :conclusion
      t.string :action, null: false
      t.string :branch, null: false
      t.jsonb :data
      t.datetime :processed_at
      t.references :compat, foreign_key: true
      t.timestamps
    end
  end
end
