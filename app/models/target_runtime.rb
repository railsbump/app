# frozen_string_literal: true

class TargetRuntime
  # Mapping of Ruby version → bundled RubyGems version.
  # Source: https://github.com/ruby/ruby/blob/vX_Y_Z/lib/rubygems.rb
  RUBYGEMS_VERSIONS = {
    "1.9.3"  => "1.8.23",
    "2.0.0"  => "2.0.0",
    "2.1.0"  => "2.2.0",
    "2.2.0"  => "2.4.5",
    "2.3.0"  => "2.5.1",
    "2.4.0"  => "2.6.8",
    "2.5.0"  => "2.7.3",
    "2.5.9"  => "2.7.6.3",
    "2.6.0"  => "3.0.1",
    "2.6.10" => "3.0.3.1",
    "2.7.0"  => "3.1.2",
    "2.7.8"  => "3.1.6",
    "3.0.0"  => "3.2.3",
    "3.0.7"  => "3.2.33",
    "3.1.0"  => "3.3.3",
    "3.1.6"  => "3.3.27",
    "3.2.0"  => "3.4.1",
    "3.2.5"  => "3.4.19",
    "3.3.0"  => "3.5.3",
    "3.3.5"  => "3.5.16",
    "3.4.0"  => "3.6.2",
    "3.4.2"  => "3.6.2",
    "3.4.8"  => "3.6.9",
    "4.0.0"  => "4.0.3"
  }.freeze

  def initialize(lockfile:, rails_release:)
    @lockfile = lockfile
    @rails_release = rails_release
  end

  def ruby_version
    max_version(lockfile.ruby_version, rails_release.minimum_ruby_version)
  end

  def rubygems_version
    max_version(rubygems_version_for_ruby(ruby_version), rails_release.minimum_rubygems_version)
  end

  def bundler_version
    max_version(lockfile.bundler_version, rails_release.minimum_bundler_version)
  end

  private

  attr_reader :lockfile, :rails_release

  def rubygems_version_for_ruby(ruby_version)
    return if ruby_version.blank?

    target = Gem::Version.new(ruby_version)
    RUBYGEMS_VERSIONS
      .select { |v, _| Gem::Version.new(v) <= target }
      .max_by { |v, _| Gem::Version.new(v) }
      &.last
  end

  def max_version(*versions)
    versions.compact_blank.max_by { |v| Gem::Version.new(v) }
  end
end
