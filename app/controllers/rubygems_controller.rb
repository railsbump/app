class RubygemsController < ApplicationController
  before_filter :set_rubygem,          only: [:show, :edit, :update]
  before_filter :unauthorize_if_ready, only: [:edit, :update]

  def index
    alphabetical = Rubygem.alphabetically

    @gems = if params[:query].present?
      alphabetical.search_by_name params[:query]
    else
      alphabetical
    end
  end

  def new
    @gem = Rubygem.new
  end

  def create
    @gem = Rubygem.new rubygem_params

    if @gem.save
      redirect_to @gem, success: "Gem successfully registered."
    else
      render :new
    end
  end

  def update
    if @gem.update rubygem_params
      redirect_to @gem, success: "Gem successfully updated."
    else
      render :edit
    end
  end

  private

  def rubygem_params
    params.require(:rubygem).permit :name, :status, :notes, :miel
  end

  def set_rubygem
    @gem = Rubygem.find_by! name: params[:id]
  end

  def unauthorize_if_ready
    redirect_to @gem if @gem.ready?
  end
end
