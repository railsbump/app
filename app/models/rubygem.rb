class Rubygem < ActiveRecord::Base
  scope :alphabetical, -> { order "name" }
  scope :recent,       -> { order("updated_at DESC").limit 20 }
  scope :by_name,      ->(name) { alphabetical.where("name ILIKE ?", "%#{name}%").limit 20 }

  def to_param
    name
  end
end
