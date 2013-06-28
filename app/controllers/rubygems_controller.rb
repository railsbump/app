require_dependency 'rubygem_cache'

class RubygemsController < ApplicationController
  before_filter :set_rubygem, only: [:show, :edit, :update]

  def index
    paginate = Rubygem.page params[:page]

    @gems = if params[:query].present?
      paginate.by_name params[:query]
    else
      RubygemCache.recent paginate
    end
  end

  def new
    @form = RubygemForm.new rubygem: Rubygem.new
  end

  def create
    @form = RubygemForm.new rubygem: Rubygem.new

    if @form.validate params[:rubygem]
      @form.save
      RubygemCache.flush_cache @form.rubygem

      redirect_to @form.rubygem, success: "Gem successfully registered."
    else
      render :new
    end
  end

  def edit
    @form = RubygemForm.new rubygem: @gem
  end

  def update
    @form = RubygemForm.new rubygem: @gem

    if @gem.validates params[:rubygem]
      @form.save
      RubygemCache.flush_cache @gem

      redirect_to @gem, success: "Gem successfully updated."
    else
      render :edit
    end
  end

  private

  def set_rubygem
    @gem = RubygemCache.find_by_name params[:id]
  end
end
