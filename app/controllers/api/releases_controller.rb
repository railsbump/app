# frozen_string_literal: true

module API
  class ReleasesController < BaseController
    def create
      if params[:name] == "rails"
        RailsReleases::Create.call_async params[:version]
      else
        gemmy = Gemmy.find_by!(name: params[:name])
        Gemmies::Process.call_async gemmy
      end

      head :ok
    end
  end
end
