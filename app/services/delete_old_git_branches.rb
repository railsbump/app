class DeleteOldGitBranches < Services::Base
  def call
    git = CheckOutGitRepo.call
    branches = git.branches.remote.map(&:name).grep(/\A\d+\z/)
    branches.in_groups_of(100, false) do |group|
      done_compats = Compat.where(id: group).where.not(compatible: nil)
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
