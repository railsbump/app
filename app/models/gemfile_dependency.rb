class GemfileDependency < ApplicationRecord
  belongs_to :gemfile
  belongs_to :gemmy
end

# == Schema Information
#
# Table name: gemfile_dependencies
#
#  gemfile_id :bigint
#  gemmy_id   :bigint
#
