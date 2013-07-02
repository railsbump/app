require_dependency "rubygem_cache"

class RubygemsController < ApplicationController
  before_filter :set_rubygem, only: [:show, :edit, :update]

  def index
    if params[:query].present?
      @gems = Rubygem.by_name params[:query]
    else
      @gems = Rubygem.recent
      fresh_when last_modified: @gems.maximum(:updated_at)
    end
  end

  def show
    fresh_when @gem, public: true
  end

  def new
    @form = RubygemForm.new rubygem: Rubygem.new
  end

  def create
    @form = RubygemForm.new rubygem: Rubygem.new

    if @form.save params[:rubygem]
      ApplicationMailer.new_gem_admin_notification(@form).deliver
      redirect_to @form.rubygem
    else
      render :new
    end
  end

  def edit
    @form = RubygemForm.new rubygem: @gem
  end

  def update
    @form = RubygemForm.new rubygem: @gem

    if @form.save params[:rubygem]
      RubygemCache.flush_by_gem @gem

      redirect_to @form.rubygem
    else
      render :edit
    end
  end

  private

  def set_rubygem
    @gem = RubygemCache.find_by_name params[:id]
  end
end
