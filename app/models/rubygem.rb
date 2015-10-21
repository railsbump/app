require "open-uri"

class Rubygem < ActiveRecord::Base
  STATUSES = ["ready", "not ready", "unknown"]

  attr_accessor :miel

  validates :name,   presence: true, uniqueness: { case_sensitive: false }
  validates :status, presence: true, inclusion: Rubygem::STATUSES
  validates :notes,  presence: true
  validates :miel,   format: { without: /.+/ }
  validate :gem_exists_in_rubygem_dot_org

  scope :alphabetical, -> { order "name" }
  scope :recent,       -> { order("updated_at DESC").limit 20 }
  scope :by_name,      ->(name)   { alphabetical.where("name ILIKE ?", "%#{name}%").limit 20 }
  scope :by_status,    ->(status) { alphabetical.where status: status }

  def to_param
    name
  end

  private

  def gem_exists_in_rubygem_dot_org
    URI.parse("https://rubygems.org/api/v1/gems/#{name}.json").read
  rescue OpenURI::HTTPError
    errors.add(:name, "is not the name of a gem registered in https://rubygems.org")
  end
end
