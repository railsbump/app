class Lockfile < ApplicationRecord
  has_many :dependencies, class_name: "LockfileDependency", dependent: :destroy
  has_many :gemmies, through: :dependencies

  validates :content, presence: true
  validates :slug,    presence: { if: -> { content.present? } }, uniqueness: { allow_blank: true }
  validates :gemmies, presence: { if: -> { content.present? } }
  validate :validate_content
  validate :validate_gemmies

  before_validation :generate_slug
  before_validation :add_gemmies

  delegate :to_param, to: :slug

  scope :with_gemmies, ->(gemmies) { joins(:gemmies).where(gemmies: { id: gemmies }).distinct }

  CONTENT_REGEX = %r(
    GEM
    .+
    DEPENDENCIES
  )xm.freeze

  def compats
    Compat.where(id: gemmies.flat_map(&:compat_ids))
  end

  def gem_names
    parser = Bundler::LockfileParser.new(content)
    parser.dependencies.keys - %w(rails)
  end

  def calculated_slug
    ActiveSupport::Digest.hexdigest(gem_names.join("#"))
  end

  private

  def add_gemmies
    return if content.blank?
    return if gemmies.any?

    gem_names.each do |gem_name|
      gemmy = Gemmy.find_by(name: gem_name) || Gemmies::Create.call(gem_name)
      self.gemmies << gemmy
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
