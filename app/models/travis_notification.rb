class TravisNotification < ApplicationRecord
  belongs_to :rails_compatibility, optional: true

  validates :rails_compatibility, presence: { if: :processed? }

  def processed?
    !!processed_at
  end
end

# == Schema Information
#
# Table name: travis_notifications
#
#  id                     :bigint           not null, primary key
#  data                   :jsonb
#  processed_at           :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  rails_compatibility_id :bigint
#
