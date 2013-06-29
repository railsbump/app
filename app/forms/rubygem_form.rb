require 'reform/rails'

class RubygemForm < Reform::Form
  include DSL
  include Reform::Form::ActiveRecord

  STATUSES = ["ready", "not ready", "unknown", "does not depend on rails version"]

  properties [:name, :status, :notes], on: :rubygem

  attr_accessor :miel # honeypot field for spammers

  model :rubygem

  validates :name,   presence: true, uniqueness: { case_sensitive: false }
  validates :status, presence: true, inclusion: STATUSES
  validates :miel,   format: { without: /.+/ }

  def save params
    rubygem.update(to_hash) if validate(params)
  end
end
