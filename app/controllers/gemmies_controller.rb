class GemmiesController < ApplicationController
  def new
    @gemmy = Gemmy.new
  end

  def create
    @gemmy = Gemmies::Create.call(gemmy_params.fetch(:name))
  rescue Gemmies::Create::AlreadyExists => e
    redirect_to e.gemmy
  rescue Gemmies::Create::Error => e
    @gemmy = Gemmy.new
    flash.now[:alert] = e.message
    render :new
  else
    redirect_to @gemmy
  end

  def index
    @gemmies = Gemmy.order(created_at: :desc).limit(20)
  end

  def show
    @gemmy = Gemmy.find_by!(name: params[:id])
  end

  private

    def gemmy_params
      params.require(:gemmy).permit(:name)
    end
end
