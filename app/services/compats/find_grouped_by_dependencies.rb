require 'gems'

module Compats
  class FindGroupedByDependencies < Services::Base
    def call(gemmy)
      dependencies = Gems.dependencies(gemmy.name)

      gemmy.compats.group_by do |compat|
        dependencies.detect do |data|
          data.fetch(:number) == compat.version.to_s
        end.fetch(:dependencies).sort
      end.transform_values do |compats|
        compats.sort_by(&:version)
      end
    end
  end
end
