class RubygemsController < ApplicationController
  def index
    @status        = params[:status]
    @rails_version = params[:rails_version]
    @query         = params[:query]

    @gems = Rubygem.page(params[:page])
    @gems = if @status
              @gems.by_name.by_status(@status, @rails_version.to_i)
            elsif @query.present?
              @gems.by_name.search(@query)
            else
              @gems.newest
            end

    unless params[:page] || @query || @status
      fresh_when last_modified: Rubygem.maximum(:updated_at), public: true
    end
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
end
