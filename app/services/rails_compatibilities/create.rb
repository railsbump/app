require 'bundler/inline'

module RailsCompatibilities
  class Create < ::Services::Base
    def call(gemmy, rails_release)
      gemmy.versions.each do |version|
        compatible = begin
          # gemfile do
          #   source 'https://rubygems.org'
          #   gem 'rails', "~> #{rails_release.version}.0"
          #   gem gemmy.name, version
          # end
        rescue Bundler::VersionConflict
          false
        else
          true
        end

        gemmy.rails_compatibilities.create! \
          rails_release: rails_release,
          version:       version,
          compatible:    compatible
      end
    end
  end
end
