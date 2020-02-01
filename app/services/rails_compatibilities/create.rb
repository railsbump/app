module RailsCompatibilities
  class Create < ::Services::Base
    def call(gemmy, rails_release)
      gemmy.versions.each do |version|
        rails_compatibility = gemmy.rails_compatibilities.create!(
          rails_release: rails_release,
          version:       version
        }
        RailsCompatibilities::Check.call_async rails_compatibility
      end
    end
  end
end
