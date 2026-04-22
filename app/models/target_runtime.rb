# frozen_string_literal: true

class TargetRuntime
  def initialize(lockfile:, rails_release:)
    @lockfile = lockfile
    @rails_release = rails_release
  end

  def ruby_version
    @ruby_version ||= max_version(@lockfile.ruby_version, ruby_min)
  end

  def rubygems_version
    RubyRubygemsVersion.for(ruby_version)
  end

  def bundler_version
    @bundler_version ||= max_version(@lockfile.bundler_version, bundler_min)
  end

  private

  def ruby_min
    @rails_release.minimum_ruby_version.presence ||
      extract_minimum_version(rails_info["ruby_version"])
  end

  def bundler_min
    @rails_release.minimum_bundler_version.presence ||
      extract_minimum_version(bundler_dep&.dig("requirements"))
  end

  def bundler_dep
    rails_info.dig("dependencies", "runtime")&.find { |d| d["name"] == "bundler" }
  end

  def rails_info
    @rails_info ||= Gems::V2.info("rails", latest_patch_version)
  end

  def latest_patch_version
    major_minor = @rails_release.version.to_s

    Gems.versions("rails")
      .select { |v| v["number"].start_with?("#{major_minor}.") && !v["prerelease"] }
      .map { |v| v["number"] }
      .max_by { |v| Gem::Version.new(v) } || "#{major_minor}.0"
  end

  def extract_minimum_version(requirement_string)
    return nil if requirement_string.blank?

    Gem::Requirement.new(requirement_string.split(",").map(&:strip))
      .requirements
      .select { |op, _| op == ">=" }
      .map { |_, v| v.to_s }
      .min_by { |v| Gem::Version.new(v) }
  end

  def max_version(a, b)
    return a if b.nil?
    return b if a.nil?

    [Gem::Version.new(a), Gem::Version.new(b)].max.to_s
  end
end
