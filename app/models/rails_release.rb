class RailsRelease < ApplicationRecord
  # Define the repository, workflow file, and branch
  GITHUB_REPO = 'railsbump/checker'
  GITHUB_WORKFLOW = 'rails_release_sanity_check.yml'
  GITHUB_REF = 'main'

  composed_of :version,
    class_name: "Gem::Version",
    mapping:    %w(version to_s),
    converter:  Gem::Version.method(:new)

  has_many :compats, dependent: :destroy

  validates :version, presence: true, format: { with: /\A\d+\.\d+\z/, allow_blank: true }

  validate do
    if version
      scope = self.class.where(version: version)
      if persisted?
        scope.where.not(id: id)
      end
      if scope.any?
        errors.add :version, "is a duplicate"
      end
    end
  end

  scope :latest_major, -> {
    pluck(:version)
      .group_by { _1[/\A\d+/] }
      .sort_by(&:first)
      .last(2)
      .to_h
      .values
      .map(&:max)
      .then {
        where(version: _1).order(:version)
      }
  }

  def to_s
    "Rails #{version}"
  end

  def earlier?
    !self.class.latest_major.exists?(id: self)
  end

  def self.print_all
    all.each do |release|
      puts "# #{release}"

      puts "Minimum ruby version: #{release.minimum_ruby_version}"
      puts "Minimum bundler version: #{release.minimum_bundler_version}"
      puts "Minimum rubygems version: #{release.minimum_rubygems_version}"
    end
  end

  def compatible_ruby_version
    if version
      Gem::Version.new(version < Gem::Version.new("5") ? "2.7" : RUBY_VERSION)
    end
  end

  def compatible_bundler_version
    if version
      Gem::Version.new(version < Gem::Version.new("5") ? "1.17.3" : Bundler::VERSION)
    end
  end

  def github_actions_sanity_check!
    # Initialize the Octokit client with your GitHub token
    client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])

    # Trigger the workflow dispatch event
    client.workflow_dispatch(GITHUB_REPO, GITHUB_WORKFLOW, GITHUB_REF, inputs: github_action_inputs)
  end

  def to_param
    "rails-#{version.to_s.gsub(".", "-")}"
  end

  private

  # Define the github_action_inputs for the workflow
  def github_action_inputs
    {
      rails_version: version.to_s,
      ruby_version: minimum_ruby_version.to_s,
      bundler_version: minimum_bundler_version.to_s
    }
  end
end

# == Schema Information
#
# Table name: rails_releases
#
#  id         :integer          not null, primary key
#  version    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
