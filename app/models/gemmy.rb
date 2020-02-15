class Gemmy < ApplicationRecord
  validates :name, presence: true, uniqueness: { allow_blank: true }

  delegate :to_param, :to_s, to: :name

  def dependencies
    dependencies_and_versions.keys.map(&JSON.method(:parse))
  end
end

# == Schema Information
#
# Table name: gemmies
#
#  id                        :bigint           not null, primary key
#  name                      :string
#  dependencies_and_versions :jsonb
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
