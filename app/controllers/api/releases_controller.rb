module API
  class ReleasesController < BaseController
    def create
      Rollbar.error 'RubyGems release', params: params

      # if params[:name] == 'rails'
      #   RailsReleases::Create.call(params[:version])
      # else
      #   Gemmies::Create.call(params[:name])
      # end

      head :ok
    end
  end
end
