class GithubNotification < ApplicationRecord
  include HasTimestamps[:processed_at]

  belongs_to :compat, optional: true

  validates :compat, presence: { if: :processed? }

  def processed?
    !!processed_at
  end
end

# == Schema Information
#
# Table name: github_notifications
#
#  id           :bigint           not null, primary key
#  data         :jsonb
#  processed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  compat_id    :bigint
#
