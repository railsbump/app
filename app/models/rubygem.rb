class Rubygem < ActiveRecord::Base
  STATUSES = ["ready", "not ready", "unknown"]

  attr_accessor :miel # honeypot field for spammers
  validates_format_of :miel, without: /.+/

  validates :name,   presence: true, uniqueness: true
  validates :status, presence: true, inclusion: STATUSES

  scope :recent,  -> { order "updated_at DESC" }
  scope :by_name, ->(name) { where("name ILIKE '%#{name}%'").order "name" }

  def ready?
    status == "ready"
  end

  def to_param
    name
  end
end
