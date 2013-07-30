require_dependency "rubygem_cache"

class RubygemsController < ApplicationController
  before_action :set_rubygem,  only: [:show, :edit, :update]
  before_action :set_statuses, only: [:index, :statuses]

  def index
    @gems = Rubygem.recent

    fresh_when @gems, last_modified: RubygemCache.maximum_updated_at, public: true
  end

  def search
    @gems = Rubygem.by_name params[:query]

    render :index
  end

  def statuses
    status = params[:status]

    raise_if_not_included Rubygem::STATUSES, status

    @gems = Rubygem.by_status(status).page params[:page]
    
    render :status
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
      RubygemCache.flush
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
      ApplicationMailer.updated_gem_admin_notification(@form.rubygem).deliver

      redirect_to @form.rubygem
    else
      render :edit
    end
  end

  private

  def set_rubygem
    @gem = RubygemCache.find_by_name params[:id]
  end

  def set_statuses
    @total_count  = RubygemCache.total_count
    @count_status = RubygemCache.count_by_status
  end

  def raise_if_not_included array, value
    return if array.include?(value)

    expected = array.to_sentence last_word_connector: ' or '
    message  = "Given #{value.inspect} param is not #{expected}"

    raise ActionController::RoutingError.new(message)
  end
end
