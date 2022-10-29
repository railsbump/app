# frozen_string_literal: true

class LockfilesController < ApplicationController
  def new
    @lockfile = Lockfile.new
  end

  def create
    @lockfile = Lockfiles::Create.call(lockfile_params.fetch(:content).strip)
  rescue Lockfiles::Create::AlreadyExists => error
    redirect_to error.lockfile,
      status: :see_other
  rescue Lockfiles::Create::Error => error
    @lockfile = Lockfile.new(lockfile_params)
    flash.now[:alert] = error.message
    render :new
  else
    redirect_to @lockfile,
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
