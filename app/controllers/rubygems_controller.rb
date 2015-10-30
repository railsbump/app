class RubygemsController < ApplicationController
  before_action :get_counts, only: [:index, :search, :statuses]

  def index
    @gems = Rubygem.recent

    fresh_when @gems, last_modified: Rubygem.maximum(:updated_at), public: true
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
    @gem = Rubygem.find_by_name params[:id]
    fresh_when @gem, public: true
  end

  def new
    @rubygem = Rubygem.new
  end

  def create
    @rubygem = Rubygem.new params[:rubygem].permit!

    if @rubygem.save
      ApplicationMailer.new_gem_admin_notification(@rubygem).deliver
      redirect_to @rubygem
    else
      render :new
    end
  end

  private

  def get_counts
    @total_count  = Rubygem.count
    @count_status = Rubygem.group(:status).count
  end

  def raise_if_not_included array, value
    return if array.include?(value)

    expected = array.to_sentence last_word_connector: ' or '
    message  = "Given #{value.inspect} param is not #{expected}"

    raise ActionController::RoutingError.new(message)
  end
end
