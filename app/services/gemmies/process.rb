# frozen_string_literal: true

module Gemmies
  class Process < Services::Base
    def call(gemmy)
      UpdateDependenciesAndVersions.call(gemmy)
      UpdateCompats.call(gemmy)

      Compats::CheckAllUnchecked.call_async
    end
  end
end
