class GemmiesController < ApplicationController
  def new
    @gemmy = Gemmy.new
  end

  def create
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
    @gemmy = Gemmy.find_by_name!(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: gemmy_compatibility_json(@gemmy) }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { raise }
      format.json { render json: { error: "Gem not found" }, status: :not_found }
    end
  end

  def compat_table
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
