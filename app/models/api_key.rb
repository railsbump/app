class APIKey < ApplicationRecord
  validates :name, :key, presence: true, uniqueness: true
  validates :name, length: { maximum: 50 }
  validates :key, length: { minimum: 64, maximum: 255 }
end
