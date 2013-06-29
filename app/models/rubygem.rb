class Rubygem < ActiveRecord::Base
  scope :alphabetical, -> { order "name" }
  scope :recent,       -> { order "updated_at DESC" }
  scope :by_name,      ->(name) { alphabetical.where("name ILIKE '%#{name}%'") }

  def to_param
    name
  end
end
