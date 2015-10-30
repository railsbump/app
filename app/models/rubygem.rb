require "open-uri"

class Rubygem < ActiveRecord::Base
  STATUSES = ["ready", "not ready", "unknown"]

  attr_accessor :miel

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :status_rails4, :status_rails5, presence: true, inclusion: Rubygem::STATUSES
  validates :notes_rails4, presence: true, unless: Proc.new { |rubygem| rubygem.status_rails4 == "unknown" }
  validates :notes_rails5, presence: true, unless: Proc.new { |rubygem| rubygem.status_rails5 == "unknown" }
  validates :miel, format: { without: /.+/ }
  validate  :gem_exists_in_rubygem_dot_org

  scope :by_name, -> { order "name" }
  scope :recent,  -> { order(updated_at: :desc).limit 20 }

  def self.search query
    where("name ILIKE ?", "%#{query}%")
  end

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
