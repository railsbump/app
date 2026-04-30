class LockfilesController < ApplicationController
  def new
    @lockfile = Lockfile.new
  end

  def create
    if FeatureFlags.new_check_flow?
      create_new_flow
    else
      create_legacy_flow
    end
  end

  def show
    if FeatureFlags.new_check_flow?
      @lockfile = Lockfile.includes(lockfile_checks: [:rails_release, :gem_checks]).find_by!(slug: params[:id])
      render :show_new
    else
      @lockfile = Lockfile.find_by!(slug: params[:id])
    end
  end

  private

    def create_new_flow
      result = Lockfile::Inspection.call(lockfile_params.fetch(:content))

      case result.reason
      when :runnable
        @lockfile = result.lockfile
        @lockfile.save!
        @lockfile.run_check!
        redirect_to @lockfile, status: :see_other
      else
        redirect_to new_lockfile_path, flash: { alert: result.message }
      end
    end

    def create_legacy_flow
      @lockfile = Lockfiles::Create.call(lockfile_params.fetch(:content).strip)

      if @lockfile.valid?
        redirect_to @lockfile, status: :see_other
      else
        redirect_to new_lockfile_path, flash: { alert: @lockfile.errors.full_messages.join(". ") }
      end
    rescue Lockfiles::Create::AlreadyExists => error
      redirect_to error.lockfile, status: :see_other
    end

    def lockfile_params
      params.require(:lockfile).permit(:content)
    end
end
