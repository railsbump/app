require 'gems'

module RailsCompatibilities
  class FindGroupedByDependencies < Services::Base
    def call(gemmy)
      dependencies = Gems.dependencies(gemmy.name)

      gemmy.rails_compatibilities.group_by do |rails_compatibility|
        dependencies.detect do |data|
          data.fetch(:number) == rails_compatibility.version.to_s
        end.fetch(:dependencies).sort
      end
    end
  end
end
