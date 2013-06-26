class Rubygem < ActiveRecord::Base
  STATUSES = ['compatible', 'not compatible', 'unknown']

  validates :name, :presence, uniqueness: true
  validates :compatibility_status, :presence, inclusion: STATUSES
end
