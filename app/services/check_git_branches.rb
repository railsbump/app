class CheckGitBranches < Services::Base
  def call
    git       = CheckOutGitRepo.call
    branches  = git.branches.remote.map(&:name).grep(/\A\d+\z/)
    threshold = 2.hours.ago

    branches.in_groups_of(100, false) do |group|
      pending_compats, done_compats = Compat.find(group).partition(&:pending?) # Use `.find` to make sure an error is raised
                                                                               # unless all branches have a corresponding compat

      long_pending_compats = pending_compats.select { _1.checked_before?(threshold) }
      if long_pending_compats.any?
        raise Error, 'Some compats have been pending for a long time.' \
          rescue Rollbar.error $!, compat_ids: long_pending_compats.map(&:id)
      end

      if done_compats.any?
        git.push 'origin', done_compats.map(&:id), delete: true
      end
    end
  ensure
    if git && File.exist?(git.dir.path)
      FileUtils.rm_rf git.dir.path
    end
  end
end
