class Rubygem < ActiveRecord::Base
  scope :recent,  -> { order "updated_at DESC" }
  scope :by_name, ->(name) { where("name ILIKE '%#{name}%'").order "name" }

  def to_param
    name
  end
end
