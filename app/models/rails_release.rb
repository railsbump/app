class RailsRelease < ApplicationRecord
  include HasVersion

  validates :version, presence: true, format: { with: /\A\d+\.\d+\z/, allow_blank: true }

  has_many :rails_compatibilities
  has_many :compatible_gemmies, through: :rails_compatibilities

  scope :latest_major, -> {
    versions = pluck(:version).group_by { |version| version[/\A\d+/] }
                              .values
                              .map(&:max)
    order(:version).where(version: versions)
  }
end

# == Schema Information
#
# Table name: rails_releases
#
#  id         :bigint           not null, primary key
#  version    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
