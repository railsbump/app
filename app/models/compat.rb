class Compat < ApplicationRecord
  include HasTimestamps[:checked_at]

  belongs_to :rails_release

  validates :dependencies, uniqueness: { scope: :rails_release }

  scope :compatible,   -> { where(compatible: true) }
  scope :incompatible, -> { where(compatible: false) }
  scope :pending,      -> { where(compatible: nil) }

  def to_s
    "Compatibility of #{rails_release} with #{dependencies.map { "#{_1} #{_2}" }.to_sentence}"
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
#  id               :bigint           not null, primary key
#  checked_at       :datetime
#  compatible       :boolean
#  dependencies     :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  rails_release_id :bigint
#
