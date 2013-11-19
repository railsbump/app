ENV['DATABASE_URL'] = ENV['TEST_DATABASE_URL']

require 'cuba/test'
require_relative '../app'

class Cutest::Scope
  def test(*)
    result = nil
    DB.transaction(rollback: :always) { result = super }
    result
  end
end
