require "gems"

module Gemmies
  class UpdateCompats < Baseline::Service
    def call(gemmy)
      check_uniqueness gemmy.id

      RailsRelease.find_each do |rails_release|
        gemmy.dependencies.each do |dependencies|
          unless rails_release.compats.where("dependencies::jsonb = ?", dependencies.to_json).exists?
            rails_release.compats.create! dependencies: dependencies
          end
        end
      end

      compats = gemmy.dependencies.flat_map do |dependencies|
        Compat.where("dependencies::jsonb = ?", dependencies.to_json).to_a
      end

      gemmy.update! compat_ids: compats.pluck(:id).sort
    end
  end
end
