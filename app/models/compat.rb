class Compat < ApplicationRecord
  include HasTimestamps[:checked_at]

  belongs_to :rails_release

  has_one :github_notification

  validates :dependencies, uniqueness: { scope: :rails_release }
  validates :compatible_reason, presence: { unless: :pending? }, absence: { if: :pending? }

  scope :compatible,     -> { where(compatible: true) }
  scope :incompatible,   -> { where(compatible: false) }
  scope :pending,        -> { where(compatible: nil) }
  scope :with_gem_names, ->(gem_names) { where('dependencies ?& array[:gem_names]', gem_names: gem_names) }

  def to_s
    "Compatibility of #{rails_release} with #{dependencies.map { "#{_1} #{_2}" }.to_sentence}"
  end

  def gemmies
    Gemmy.with_dependencies(dependencies)
  end

  def lockfiles
    Lockfile.with_gemmies(gemmies)
  end

  def incompatible?
    compatible == false
  end

  def pending?
    compatible.nil?
  end

  # Sort dependencies, by default JSONB does not preserve key order.
  def dependencies
    super.sort.to_h
  end
end

# == Schema Information
#
# Table name: compats
#
#  id                :bigint           not null, primary key
#  checked_at        :datetime
#  compatible        :boolean
#  compatible_reason :string
#  dependencies      :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  rails_release_id  :bigint
#
