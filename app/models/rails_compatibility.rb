class RailsCompatibility < ApplicationRecord
  include HasVersion

  belongs_to :gemmy
  belongs_to :rails_release

  validates :compatible, inclusion: [true, false]
  validates :version, inclusion:  { in: -> { gemmy.versions }, if: :gemmy },
                      uniqueness: { scope: %i(gemmy rails_release) }
end

# == Schema Information
#
# Table name: rails_compatibilities
#
#  compatible       :boolean
#  version          :string
#  gemmy_id         :bigint
#  rails_release_id :bigint
#
