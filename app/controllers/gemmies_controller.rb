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
  end

  def compat_table
    render locals: {
      gemmies: Gemmy.find(params[:gemmy_ids].split(",")),
      inaccessible_gemmies: InaccessibleGemmy.find(inaccessible_gemmy_ids),
      hide_gem_name: params.key?(:hide_gem_name)
    }
  end

  private

    def gemmy_params
      params.require(:gemmy).permit(:name)
    end

    def inaccessible_gemmy_ids
      ps = params[:inaccessible_gemmy_ids] || ""

      ps.split(",")
    end
end
