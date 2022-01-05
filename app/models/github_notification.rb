class GithubNotification < ApplicationRecord
  include HasTimestamps[:processed_at]

  CONCLUSIONS = %w(success failure skipped cancelled)

  belongs_to :compat, optional: true

  validates :action, presence: true
  validates :branch, presence: true
  validates :conclusion, inclusion: { in: CONCLUSIONS, if: -> { action == "completed" } }

  def self.actions
    pluck(Arel.sql("DISTINCT action")).sort
  end

  def method_missing(method, *args, &block)
    method_action = method.to_s.sub(/\?\z/, '')

    if method_action.in?(self.class.actions)
      action == method_action
    else
      super
    end
  end
end

# == Schema Information
#
# Table name: github_notifications
#
#  id           :bigint           not null, primary key
#  action       :string           not null
#  branch       :string           not null
#  conclusion   :string
#  data         :jsonb
#  processed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  compat_id    :bigint
#
