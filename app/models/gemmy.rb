class Gemmy < ApplicationRecord
  validates :name, presence: true, uniqueness: { allow_blank: true }

  has_many :rails_compatibilities
  has_many :compatible_rails_releases, through: :rails_compatibilities

  delegate :to_param, to: :name

  def versions=(value)
    super value.map(&:to_s)
  end

  def versions
    super.map(&Gem::Version.method(:new))
  end
end

# == Schema Information
#
# Table name: gemmies
#
#  id         :bigint           not null, primary key
#  name       :string
#  versions   :text             default([]), not null, is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
