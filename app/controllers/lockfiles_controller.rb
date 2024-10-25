class LockfilesController < ApplicationController
  def new
    @lockfile = Lockfile.new
  end

  def create
    @lockfile = Lockfiles::Create.call(lockfile_params.fetch(:content).strip)

    if @lockfile.valid?
      redirect_to @lockfile, status: :see_other
    else
      redirect_to new_lockfile_path, flash: { alert: @lockfile.errors.full_messages.join(". ") }
    end
  rescue Lockfiles::Create::AlreadyExists => error
    redirect_to error.lockfile,
      status: :see_other
  end

  def show
    @lockfile = Lockfile.find_by!(slug: params[:id])
  end

  private

    def lockfile_params
      params.require(:lockfile).permit(:content)
    end
end
