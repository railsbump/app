class GemCheck < ApplicationRecord
  belongs_to :lockfile_check

  RUBYGEMS_SOURCE = "https://rubygems.org/"

  validates :gem_name, presence: true
  validates :status, inclusion: { in: %w[pending complete] }
  validates :result, inclusion: { in: %w[compatible upgrade_needed incompatible skipped] }, allow_nil: true

  def resolvable?
    source == RUBYGEMS_SOURCE && locked_version.present?
  end
end
