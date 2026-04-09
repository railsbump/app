# frozen_string_literal: true

class RubyRubygemsVersion
  VERSIONS = YAML.load_file(Rails.root.join("config/ruby_rubygems_versions.yml")).freeze

  # Returns the RubyGems version bundled with the given Ruby version.
  # Falls back to the closest known version if an exact match isn't found.
  def self.for(ruby_version)
    return nil if ruby_version.blank?

    VERSIONS[ruby_version] || closest_match(ruby_version)
  end

  def self.closest_match(ruby_version)
    target = Gem::Version.new(ruby_version)

    VERSIONS
      .select { |v, _| Gem::Version.new(v) <= target }
      .max_by { |v, _| Gem::Version.new(v) }
      &.last
  end

  private_class_method :closest_match
end
