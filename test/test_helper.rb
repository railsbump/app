ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/setup'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  def self.test_order
    :random
  end
end

class ActionController::TestCase
  include Blind
end
