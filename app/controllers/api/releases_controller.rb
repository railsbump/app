module API
  class ReleasesController < BaseController
    def create
      name = params.fetch(:name)

      if name == "rails"
        RailsReleases::Create.call_async params.fetch(:version)
      else
        Gemmy.find_by(name: name)&.then {
          Gemmies::Process.call_async _1
        }
      end

      head :ok
    end
  end
end
