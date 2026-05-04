class GemmiesController < ApplicationController
  def new
    @gemmy = Gemmy.new
  end

  def create
    Sentry.capture_message(
      "POST /gems hit (legacy gem submission)",
      level: :info,
      extra: {
        name:       gemmy_params[:name],
        remote_ip:  request.remote_ip,
        user_agent: request.user_agent,
        referer:    request.referer
      }
    )

    @gemmy = Gemmies::Create.call(gemmy_params.fetch(:name))
  rescue Gemmies::Create::AlreadyExists => error
    redirect_to error.gemmy,
      status: :see_other
  rescue Gemmies::Create::Error => error
    @gemmy = Gemmy.new
    flash.now[:alert] = error.message
    render :new,
      status: :unprocessable_content
  else
    redirect_to @gemmy,
      status: :see_other
  end

  def index
    @gemmies = Gemmy.order(created_at: :desc).limit(20)
    @inaccessible_gemmies = []
  end

  def show
    if rand < 0.01
      Sentry.capture_message(
        "GET /gems/:id hit (legacy gem page, 1% sample)",
        level: :info,
        extra: {
          name:       params[:id],
          remote_ip:  request.remote_ip,
          user_agent: request.user_agent,
          referer:    request.referer
        }
      )
    end

    @gemmy = Gemmy.find_by_name(params[:id])

    if @gemmy
      respond_to do |format|
        format.html
        format.json { render json: gemmy_compatibility_json(@gemmy) }
      end
    else
      respond_to do |format|
        format.html { head :not_found }
        format.json { render json: { error: "Gem not found" }, status: :not_found }
      end
    end
  end

  def compat_table
    Sentry.capture_message(
      "GET /gems/compat_table hit (legacy)",
      level: :info,
      extra: {
        gemmy_ids:             params[:gemmy_ids],
        inaccessible_gemmy_ids: params[:inaccessible_gemmy_ids],
        remote_ip:             request.remote_ip,
        user_agent:            request.user_agent,
        referer:               request.referer
      }
    )

    render locals: {
      gemmies: Gemmy.find(gemmy_ids),
      inaccessible_gemmies: InaccessibleGemmy.find(inaccessible_gemmy_ids),
      hide_gem_name: params.key?(:hide_gem_name)
    }
  end

  private

    def gemmy_compatibility_json(gemmy)
      rails_releases = RailsRelease.all.sort_by { |release| Gem::Version.new(release.version.to_s) }

      {
        name: gemmy.name,
        compatibility: rails_releases.map { |rails_release|
          compats = gemmy.compats_for_rails_release(rails_release)
          status = helpers.compats_status(gemmy, compats)

          {
            rails_version: rails_release.version.to_s,
            status: status.to_s,
            compats: compats.map { |compat|
              {
                id: compat.id,
                status: compat.status,
                dependencies: compat.dependencies,
                checked_at: compat.checked_at
              }
            }
          }
        }
      }
    end

    def gemmy_params
      params.require(:gemmy).permit(:name)
    end

    def gemmy_ids
      ps = params[:gemmy_ids] || ""

      ps.split(",")
    end

    def inaccessible_gemmy_ids
      ps = params[:inaccessible_gemmy_ids] || ""

      ps.split(",")
    end
end
