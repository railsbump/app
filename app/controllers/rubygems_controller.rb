require_dependency "rubygem_cache"

class RubygemsController < ApplicationController
  before_action :set_statuses, only: [:index, :search, :statuses]

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
    @gem = RubygemCache.find_by_name params[:id]
    fresh_when @gem, public: true
  end

  def new
    @rubygem = Rubygem.new
  end

  def create
    @rubygem = Rubygem.new params[:rubygem].permit!

    if @rubygem.save
      RubygemCache.flush
      ApplicationMailer.new_gem_admin_notification(@rubygem).deliver
      redirect_to @rubygem
    else
      render :new
    end
  end

  private

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
