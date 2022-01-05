class LockfilesController < ApplicationController
  def new
    @lockfile = Lockfile.new

    flash.now[:info] = %(Please note: if your lockfile contains many gems, the request to view the check results might time out due to #{view_context.link_to "Heroku's 30 second request limit", "https://devcenter.heroku.com/articles/request-timeout"}. You will most likely see a page saying "Application error". If that happens, please try reloading once, since the caching might then have kicked in and the page can be displayed. If the error persists, please #{view_context.link_to "open a GitHub issue", "https://github.com/railsbump/app/issues/new"}. Sorry for the inconvenience, we are working on improving this situation!)
  end

  def create
    @lockfile = Lockfiles::Create.call(lockfile_params.fetch(:content).strip)
  rescue Lockfiles::Create::AlreadyExists => e
    redirect_to e.lockfile
  rescue Lockfiles::Create::Error => e
    @lockfile = Lockfile.new(lockfile_params)
    flash.now[:alert] = e.message
    render :new
  else
    redirect_to @lockfile
  end

  def show
    @lockfile = Lockfile.find_by!(slug: params[:id])
  end

  private

    def lockfile_params
      params.require(:lockfile).permit(:content)
    end
end
