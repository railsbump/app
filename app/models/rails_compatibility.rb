class RailsCompatibility < ApplicationRecord
  include HasVersion

  belongs_to :gemmy
  belongs_to :rails_release

  validates :compatible, inclusion: { in: [true, false], allow_nil: true }
  validates :version, inclusion: { in: ->(rails_compatibility) { rails_compatibility.gemmy.versions }, if: :gemmy }

  validate do
    if gemmy && rails_release && version
      scope = self.class.where(gemmy: gemmy, rails_release: rails_release, version: version)
      if persisted?
        scope = scope.where.not(id: id)
      end
      if scope.any?
        errors.add :version, 'is a duplicate'
      end
    end
  end
end

# == Schema Information
#
# Table name: rails_compatibilities
#
#  id               :bigint           not null, primary key
#  compatible       :boolean
#  version          :string
#  gemmy_id         :bigint
#  rails_release_id :bigint
#