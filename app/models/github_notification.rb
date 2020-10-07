class GithubNotification < ApplicationRecord
  include HasTimestamps[:processed_at]

  CONCLUSIONS = {
    valid:   %w(success failure),
    invalid: %w(skipped cancelled)
  }

  belongs_to :compat, optional: true

  validates :compat, presence: { if: :processed? }
  validates :action, presence: true
  validates :branch, presence: true
  validates :conclusion, inclusion: { in: CONCLUSIONS.values.flatten, if: -> { action == 'completed' } }

  CONCLUSIONS.each do |conclusion_group, conclusions|
    scope "#{conclusion_group}_conclusion", -> { where(conclusion: conclusions) }

    define_method "#{conclusion_group}_conclusion?" do
      conclusion.in?(conclusions)
    end
  end

  def self.actions
    pluck(Arel.sql('DISTINCT action')).sort
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
