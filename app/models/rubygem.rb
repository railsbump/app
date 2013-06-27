class Rubygem < ActiveRecord::Base
  STATUSES = ["ready", "not ready", "unknown"]

  validates :name,   presence: true, uniqueness: true
  validates :status, presence: true, inclusion: STATUSES

  scope :alphabetically, -> { order "name" }
  scope :search_by_name, ->(name) { where "name ILIKE '%#{name}%'" }

  def to_param
    name
  end
end
