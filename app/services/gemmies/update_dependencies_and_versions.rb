require "gems"

module Gemmies
  class UpdateDependenciesAndVersions < Services::Base
    def call(gemmy)
      dependencies_and_versions = Gems.dependencies(gemmy.name).each_with_object({}) do |data, hash|
        key = JSON.generate(data.fetch(:dependencies).sort.to_h)
        hash[key] ||= []
        hash[key] << data.fetch(:number)
      end
      gemmy.update! dependencies_and_versions: dependencies_and_versions
    end
  end
end
