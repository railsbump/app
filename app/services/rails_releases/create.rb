module RailsReleases
  class Create < Services::Base
    def call(version)
      parsed_version = Gem::Version.new(version)

      return if parsed_version.prerelease? || parsed_version < Gem::Version.new('2.3')

      major, minor        = parsed_version.canonical_segments
      major_minor_version = "#{major}.#{minor || 0}"

      return if RailsRelease.exists?(version: major_minor_version)

      rails_release = RailsRelease.create!(version: major_minor_version)

      Process.call_async rails_release

      rails_release
    end
  end
end
