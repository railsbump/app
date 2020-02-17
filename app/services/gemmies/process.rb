module Gemmies
  class Process < Services::Base
    def call(gemmy)
      UpdateVersions.call(gemmy)
      FindOrCreateCompats.call(gemmy)
      Compats::CheckAllUnchecked.call_async
    end
  end
end
