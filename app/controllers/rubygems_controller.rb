require_dependency 'rubygem_cache'

class RubygemsController < ApplicationController
  http_basic_authenticate_with name: ENV['LOGIN'], password: ENV['PASSWORD'], only: [:new, :create]

  before_filter :set_rubygem,          only: [:show, :edit, :update]
  before_filter :unauthorize_if_ready, only: [:edit, :update]

  def index
    paginate = Rubygem.page params[:page]

    @gems = if params[:query].present?
      paginate.by_name params[:query]
    else
      RubygemCache.recent paginate
    end
  end

  def new
    @gem = Rubygem.new
  end

  def create
    @gem = Rubygem.new rubygem_params

    if @gem.save
      RubyGemCache.flush_cache
      redirect_to @gem, success: "Gem successfully registered."
    else
      render :new
    end
  end

  def update
    if @gem.update rubygem_params
      RubyGemCache.flush_cache
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
    @gem = RubygemCache.find_by_name params[:id]
  end

  def unauthorize_if_ready
    redirect_to @gem if @gem.ready?
  end
end
