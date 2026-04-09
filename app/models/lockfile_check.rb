class LockfileCheck < ApplicationRecord
  belongs_to :lockfile
  belongs_to :rails_release
  has_many :gem_checks, dependent: :destroy

  validates :status, inclusion: { in: %w[pending complete failed] }
end
