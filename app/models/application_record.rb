class ApplicationRecord < ActiveRecord::Base
  include Baseline::ModelExtensions
  primary_abstract_class
end
