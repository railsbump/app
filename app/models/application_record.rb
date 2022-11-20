# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Baseline::ModelExtensions
  primary_abstract_class
end
