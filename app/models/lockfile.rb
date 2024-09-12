class Lockfile < ApplicationRecord
  has_many :dependencies, class_name: "LockfileDependency", dependent: :destroy
  has_many :gemmies, through: :dependencies

  validates :content, presence: true
  validates :slug,    presence: { if: -> { content.present? } }, uniqueness: { allow_blank: true }
  validates :gemmies, presence: { if: -> { content.present? } }

  delegate :to_param, to: :slug

  scope :with_gemmies, ->(gemmies) { joins(:gemmies).where(gemmies: { id: gemmies }).distinct }

  def compats
    Compat.where(id: gemmies.flat_map(&:compat_ids))
  end
end

# == Schema Information
#
# Table name: lockfiles
#
#  id         :integer          not null, primary key
#  content    :text
#  slug       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
