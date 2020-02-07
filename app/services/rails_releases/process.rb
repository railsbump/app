module RailsReleases
  class Process < Services::Base
    def call(rails_release)
      Gemmy.find_each do |gemmy|
        gemmy.versions.each do |version|
          gemmy.rails_compatibilities.where(
            rails_release: rails_release,
            version:       version
          ).first_or_create!
        end

        RailsCompatibilities::FindGroupedByDependencies.call(gemmy).values.each do |rails_compatibilities|
          rails_compatibility = rails_compatibilities.detect { |rails_compatibility| rails_compatibility.rails_release == rails_release }
          RailsCompatibilities::Check.call rails_compatibility
        end
      end
    end
  end
end
