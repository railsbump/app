module RailsReleases
  class Create < ::Services::Base
    def call(version)
      parsed_version = Gem::Version.new(version)

      return if parsed_version.prerelease? || parsed_version < Gem::Version.new('3.0')

      major, minor = parsed_version.canonical_segments

      rails_release_version = "#{major}.#{minor || 0}"

      return if RailsRelease.exists?(version: rails_release_version)

      rails_release = RailsRelease.create!(version: rails_release_version)

      Gemmy.find_each do |gemmy|
        RailsCompatibilities::Create.call_async gemmy, rails_release
      end
    end
  end
end
