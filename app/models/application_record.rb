class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.inherited(subclass)
    super

    if subclass.table_exists?
      timestamps = %w(created_at updated_at).select do |timestamp|
        subclass.column_names.include?(timestamp)
      end
      if timestamps.any?
        subclass.include HasTimestamps[*timestamps]
      end
    end
  end
end
