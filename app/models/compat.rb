class Compat < ApplicationRecord
  include HasVersion, HasTimestamps[:checked_at]

  belongs_to :gemmy
  belongs_to :rails_release

  validates :compatible, inclusion: { in: [true, false], allow_nil: true }
  validates :version, inclusion: { in: ->(compat) { compat.gemmy.versions }, if: :gemmy }

  validate do
    if gemmy && rails_release && version
      scope = self.class.unscoped.where(gemmy: gemmy, rails_release: rails_release, version: version)
      if persisted?
        scope = scope.where.not(id: id)
      end
      if scope.any?
        errors.add :version, 'is a duplicate'
      end
    end
  end

  def to_s
    "Compatibility of #{gemmy} #{version} with #{rails_release}"
  end

  def incompatible
    compatible == false
  end
end

# == Schema Information
#
# Table name: compats
#
#  id               :bigint           not null, primary key
#  compatible       :boolean
#  version          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  gemmy_id         :bigint
#  rails_release_id :bigint
#
