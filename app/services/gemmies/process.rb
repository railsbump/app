module Gemmies
  class Process < Services::Base
    def call(gemmy)
      gemmy.versions.each do |version|
        RailsRelease.find_each do |rails_release|
          gemmy.rails_compatibilities.where(
            rails_release: rails_release,
            version:       version
          ).first_or_create!
        end
      end

      RailsCompatibilities::FindGroupedByDependencies.call(gemmy).values.each do |rails_compatibilities|
        rails_compatibilities.uniq(&:rails_release).each do |rails_compatibility|
          RailsCompatibilities::Check.call rails_compatibility
        end
      end
    end
  end
end
