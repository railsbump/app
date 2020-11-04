class Compat < ApplicationRecord
  include HasTimestamps[:checked_at]

  enum status: %i(
    pending
    compatible
    incompatible
    inconclusive
  )

  belongs_to :rails_release

  has_many :github_notifications

  validates :status, presence: true
  validates :dependencies, uniqueness: { scope: :rails_release }
  validates :status_determined_by, presence: { unless: :pending? }, absence: { if: :pending? }

  scope :with_gem_names, ->(gem_names) { where('dependencies ?& array[:gem_names]', gem_names: gem_names) }

  after_initialize do
    if new_record?
      self.status ||= :pending
    end
  end

  def to_s
    "Compatibility of #{rails_release} with #{dependencies.map { "#{_1} #{_2}" }.to_sentence}"
  end

  def gemmies
    Gemmy.with_dependencies(dependencies)
  end

  def lockfiles
    Lockfile.with_gemmies(gemmies)
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
#  id                   :bigint           not null, primary key
#  checked_at           :datetime
#  dependencies         :jsonb
#  status               :integer
#  status_determined_by :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  rails_release_id     :bigint
#
