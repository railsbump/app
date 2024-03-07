require "gems"

module Gemmies
  class UpdateDependenciesAndVersions < Baseline::Service
    def call(gemmy)
      versions = Gems
        .versions(gemmy.name)
        .select { _1.fetch("platform") == "ruby" }
        .map { _1.fetch "number" }

      deps = versions.each_with_object({}) do |version, hash|
        cache_key = [
          :deps,
          gemmy.name,
          version
        ].join(":")
        key = Rails.cache.fetch(cache_key) do
          Gems::V2
            .info(gemmy.name, version)
            .deep_fetch("dependencies", "runtime")
            .map(&:values)
            .sort_by(&:first)
            .to_h
            .then { JSON.generate _1 }
        end
        hash[key] ||= []
        hash[key] << version
      end

      gemmy.update! dependencies_and_versions: deps
    end
  end
end
