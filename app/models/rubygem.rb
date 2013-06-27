class Rubygem < ActiveRecord::Base
  STATUSES = ["ready", "not ready", "unknown"]

  attr_accessor :miel # honeypot field for spammers
  validates_format_of :miel, without: /.+/

  validates :name,   presence: true, uniqueness: true
  validates :status, presence: true, inclusion: STATUSES

  scope :alphabetically, -> { order "name" }
  scope :recent,         -> { order "updated_at DESC" }
  scope :by_name,        ->(name) { where "name ILIKE '%#{name}%'" }

  after_commit :flush_cache

  def self.cached_find_by_name name
    Rails.cache.fetch [self.name, name] { find_by! name: name }
  end

  def ready?
    status == "ready"
  end

  def to_param
    name
  end

  private

  def flush_cache
    Rails.cache.delete [self.class.name, name]
  end
end
