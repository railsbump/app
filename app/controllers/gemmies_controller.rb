class GemmiesController < ApplicationController
  def index
    @gemmies = Gemmy.order(:name)
  end

  def show
    @gemmy = Gemmy.find_by!(name: params[:id])
  end
end
