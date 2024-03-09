class Compat < ApplicationRecord
  include HasTimestamps[:checked_at]

  enum status: %i(
    pending
    compatible
    incompatible
    inconclusive
  )

  belongs_to :rails_release

  has_many :github_notifications

  validates :status, presence: true, inclusion: { in: %w(pending), if: :unchecked?, message: "must be pending if unchecked" }
  validates :dependencies, uniqueness: { scope: :rails_release }
  validates :status_determined_by, presence: { unless: :pending? },
                                   absence:  { if:     :pending? }

  scope :with_gem_names, ->(gem_names) { where("dependencies ?& array[:gem_names]", gem_names: gem_names) }

  after_initialize do
    if new_record?
      self.status ||= :pending
    end
  end

  def to_s
    "#{rails_release}, #{dependencies.map { "#{_1} #{_2}" }.join(", ")}"
  end

  def gemmies
    Gemmy.from("#{Gemmy.table_name}, json_each(#{Gemmy.table_name}.compat_ids)").where(json_each: { value: id.to_s })
  end

  def lockfiles
    Lockfile.with_gemmies(gemmies)
  end

  # Sort dependencies, JSON does not preserve key order.
  def dependencies
    super.sort.to_h
  end

  def dependencies=(value)
    super
    self.dependencies_key = ActiveSupport::Digest.hexdigest(JSON.generate dependencies)
  end

  def check_locally
    # Rails < 5 requires older Ruby and Bundler versions
    # which cannot easily be installed on current Linux systems,
    # so we'll only check compats for newer Rails versions locally.
    rails_release.version >= Gem::Version.new("5")
  end
end

# == Schema Information
#
# Table name: compats
#
#  id                   :integer          not null, primary key
#  checked_at           :datetime
#  dependencies         :json
#  dependencies_key     :text
#  status               :integer
#  status_determined_by :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  rails_release_id     :integer
#
