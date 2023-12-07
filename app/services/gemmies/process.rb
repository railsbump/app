module Gemmies
  class Process < Baseline::Service
    def call(gemmy)
      UpdateDependenciesAndVersions.call(gemmy)
      UpdateCompats.call(gemmy)

      Compats::CheckAllUnchecked.call_async
    end
  end
end
