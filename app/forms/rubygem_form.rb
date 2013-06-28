require 'reform/rails'

class RubygemForm < Reform::Form
  include DSL
  include Reform::Form::ActiveRecord

  STATUSES = ["ready", "not ready", "unknown"]

  properties [:name, :status, :notes], on: :rubygem

  attr_accessor :miel # honeypot field for spammers

  model :rubygem

  validates :name,   presence: true, uniqueness: true
  validates :status, presence: true, inclusion: STATUSES
  validates :miel,   format: { without: /.+/ }
end
