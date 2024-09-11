class AddMissingSequences < ActiveRecord::Migration[7.1]
  def up
    up_sequence('gemmies')
    up_sequence('compats')
    up_sequence('github_notifications')
    up_sequence('lockfiles')
    up_sequence('rails_releases')
  end

  def down
    down_sequence('gemmies')
    down_sequence('compats')
    down_sequence('github_notifications')
    down_sequence('lockfiles')
    down_sequence('rails_releases')
  end

  def down_sequence(_table_name)
    # In case of rollback, remove the sequence and reset the column default
    execute <<-SQL
      ALTER TABLE #{_table_name} ALTER COLUMN id DROP DEFAULT;
    SQL

    execute <<-SQL
      DROP SEQUENCE IF EXISTS #{_table_name}_id_seq;
    SQL
  end

  def up_sequence(_table_name)
    execute <<-SQL
      CREATE SEQUENCE IF NOT EXISTS #{_table_name}_id_seq;
    SQL

    execute <<-SQL
      ALTER TABLE #{_table_name} ALTER COLUMN id SET DEFAULT nextval('#{_table_name}_id_seq');
    SQL

    # If you have existing data, set the sequence value to the maximum current id to avoid conflicts
    execute <<-SQL
      SELECT setval('#{_table_name}_id_seq', COALESCE((SELECT MAX(id) FROM #{_table_name}), 1));
    SQL
  end
end
