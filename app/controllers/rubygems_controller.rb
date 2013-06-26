class RubygemsController < ApplicationController
  def index
    scope = Rubygem.alphabetically

    @gems = if params[:query].present?
      scope.search_by_name params[:query]
    else
      scope
    end
  end

  def show
    @gem = Rubygem.find_by! name: params[:id]
  end

  def new
    @gem = Rubygem.new
  end

  def create
    @gem = Rubygem.new rubygem_params
    if @gem.save
      redirect_to @gem, success: "Gem successfully registered"
    else
      render :new
    end
  end

  private

  def rubygem_params
    params.require(:rubygem).permit :name, :status, :notes
  end
end
