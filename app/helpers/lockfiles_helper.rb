module LockfilesHelper
  def head_title
    if @lockfile
      "Compatibility for Gemfile.lock##{@lockfile.slug}"
    else
      super
    end
  end
end
