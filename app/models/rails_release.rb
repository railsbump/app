class RailsRelease < ApplicationRecord
  composed_of :version,
    class_name: 'Gem::Version',
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
        errors.add :version, 'is a duplicate'
      end
    end
  end

  scope :latest_major, -> {
    versions = pluck(:version).group_by { _1[/\A\d+/] }
                              .values
                              .map(&:max)
    order(:version).where(version: versions)
  }

  def to_s
    "Rails #{version}"
  end

  def earlier?
    !self.class.latest_major.exists?(id: self)
  end

  def ruby_version
    if version
      {
        '2.3' => '1.9.1',
        '3.0' => '1.9.3',
        '3.1' => '1.9.3',
        '3.2' => '2.2',
        '4.0' => '2.0',
        '4.1' => '2.1',
        '4.2' => '2.2',
        '5.0' => '2.4',
        '5.1' => '2.5',
        '5.2' => '2.5'
      }[version] || '2.7'
    end
  end

  def bundler_version
    if version
      {
        '2.3' => '1.0',
        '3.0' => '1.0'
      }[version] || '2'
    end
  end
end

# == Schema Information
#
# Table name: rails_releases
#
#  id         :bigint           not null, primary key
#  version    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
