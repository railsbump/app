# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

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
