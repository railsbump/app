class InaccessibleGemmy < ApplicationRecord
  belongs_to :lockfile

  FORBIDDEN_NAMES = %w(
    new
    edit
    rails
  )

  validates :name, presence: true, uniqueness: { allow_blank: true }
  validates :name, uniqueness: { scope: :lockfile_id }

  delegate :to_param, :to_s, to: :name

  def accessible_gem?
    false
  end

  def inaccessible_gem?
    !accessible_gem?
  end

  def compats
    RailsRelease.all.map do |rails_release|
      InconclusiveCompat.build(rails_release: rails_release, status: 'inconclusive')
    end.to_a
  end

  def compats_for_rails_release(rails_release)
    InconclusiveCompat.build(rails_release: rails_release, status: 'inconclusive')
  end
end
