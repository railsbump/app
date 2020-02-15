require 'gems'

module Gemmies
  class UpdateVersions < Services::Base
    def call(gemmy)
      dependencies_and_versions = Gems.dependencies(gemmy.name).each_with_object({}) do |data, hash|
        key = data.fetch(:dependencies).sort.to_h.to_json
        hash[key] ||= []
        hash[key] << data.fetch(:number)
      end
      gemmy.update! dependencies_and_versions: dependencies_and_versions
    end
  end
end
