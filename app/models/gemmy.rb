class Gemmy < ApplicationRecord
  FORBIDDEN_NAMES = %w(
    new
    edit
    rails
  )

  validates :name, presence: true, uniqueness: { allow_blank: true }, exclusion: FORBIDDEN_NAMES

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
