class GemfilesController < ApplicationController
  def new
    @gemfile = Gemfile.new
  end

  def create
    @gemfile = Gemfiles::Create.call(gemfile_params.fetch(:content))
  rescue Gemfiles::Create::AlreadyExists => e
    redirect_to e.gemfile
  rescue Gemfiles::Create::Error => e
    @gemfile = Gemfile.new
    flash.now[:alert] = e.message
    render :new
  else
    redirect_to @gemfile
  end

  def show
    @gemfile = Gemfile.find_by!(slug: params[:id])
  end

  private

    def gemfile_params
      params.require(:gemfile).permit(:content)
    end
end
