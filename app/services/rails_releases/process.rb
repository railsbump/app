module RailsReleases
  class Process < Baseline::Service
    def call(rails_release)
      Gemmy.find_each do |gemmy|
        Gemmies::UpdateCompats.call_async(gemmy)
      end

      Compats::CheckUnchecked.call_async
    end
  end
end
