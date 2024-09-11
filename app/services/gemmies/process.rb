module Gemmies
  class Process < Baseline::Service
    def call(gemmy_id)
      gemmy = Gemmy.find(gemmy_id)
      UpdateDependenciesAndVersions.call(gemmy)
      UpdateCompats.call(gemmy)

      Compats::CheckUnchecked.perform_async
    end
  end
end
