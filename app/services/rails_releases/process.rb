module RailsReleases
  class Process < Baseline::Service
    def call(rails_release)
      Gemmy.find_each do |gemmy|
        Gemmies::UpdateCompats.perform_async(gemmy.id)
      end

      Compats::CheckUnchecked.perform_async
    end
  end
end
