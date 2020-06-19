class LockfilesController < ApplicationController
  def new
    @lockfile = Lockfile.new
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
