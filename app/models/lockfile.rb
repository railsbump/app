class Lockfile < ApplicationRecord
  has_many :dependencies, class_name: "LockfileDependency", dependent: :destroy
  has_many :gemmies, through: :dependencies
  has_many :inaccessible_gemmies, dependent: :destroy
  has_many :lockfile_checks, dependent: :destroy

  validates :content, presence: true
  validates :slug,    presence: { if: -> { content.present? } }, uniqueness: { allow_blank: true }
  validates :gemmies, presence: { if: -> { content.present? && !FeatureFlags.new_check_flow? } }
  validate :validate_content
  validate :validate_gemmies, unless: -> { FeatureFlags.new_check_flow? }

  before_validation :generate_slug
  before_validation :add_gemmies, unless: -> { FeatureFlags.new_check_flow? }

  delegate :to_param, to: :slug
  delegate :rails_version, :ruby_version, :bundler_version, :gems, to: :parsed

  scope :with_gemmies, ->(gemmies) { joins(:gemmies).where(gemmies: { id: gemmies }).distinct }

  CONTENT_REGEX = %r(
    GEM
    .+
    DEPENDENCIES
  )xm.freeze

  def parsed
    @parsed ||= Parsed.new(content)
  end

  def next_rails_release
    return unless rails_version

    RailsRelease.next_after(rails_version)
  end

  def run_check!(rails_release: next_rails_release)
    return unless rails_release

    lockfile_check = LockfileCheck.create_for!(lockfile: self, rails_release: rails_release)
    lockfile_check.enqueue_gem_checks
    lockfile_check
  end

  def compats
    Compat.where(id: gemmies.flat_map(&:compat_ids))
  end

  def gem_names
    parser = Bundler::LockfileParser.new(content)
    parser.dependencies.keys - %w(rails)
  end

  def calculated_slug
    if FeatureFlags.new_check_flow?
      SecureRandom.hex
    else
      ActiveSupport::Digest.hexdigest(gem_names.join("#"))
    end
  end

  def accessible_and_inaccessible_gemmies
    (gemmies + inaccessible_gemmies).sort_by(&:name)
  end

  private

  def add_gemmies
    return if content.blank?
    return if gemmies.any?

    gem_names.each do |gem_name|
      begin
        gemmy = Gemmy.find_by_name(gem_name) || Gemmies::Create.call(gem_name)
        self.gemmies << gemmy
      rescue Gemmies::Create::NotFound
        self.inaccessible_gemmies.build(name: gem_name)
      end
    end
  end

  def generate_slug
    return if self.slug.present?

    self.slug = calculated_slug
  end

  def validate_content
    unless CONTENT_REGEX.match?(content)
      self.errors.add(:content, "does not look like a valid lockfile.")
    end
  end

  def validate_gemmies
    parser = Bundler::LockfileParser.new(content)

    if gem_names.none?
      self.errors.add(:content, "No gems found in content.")
    end
  end
end

# == Schema Information
#
# Table name: lockfiles
#
#  id         :integer          not null, primary key
#  content    :text
#  slug       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
