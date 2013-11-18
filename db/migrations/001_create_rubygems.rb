Sequel.migration do
  change do
    create_table :rubygems do
      primary_key :id

      column :name, :varchar, null: false
      column :status, :varchar, null: false
      column :notes, :text
      column :created_at, :timestamp
      column :updated_at, :timestamp
    end
  end
end
