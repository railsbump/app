class CheckGitBranches < Baseline::Service
  def call
    check_uniqueness

    CheckOutWorkerRepo.call do |git|
      git
        .branches
        .remote
        .map(&:name)
        .grep(/\A\d+\z/)
        .in_groups_of(100, false) do |group|

        # Use `.find` to make sure an error is raised
        # unless all branches have a corresponding compat.
        done_compats = Compat.find(group).reject(&:pending?)

        if done_compats.any?
          git.push "origin", done_compats.map(&:id), delete: true
        end
      end
    end
  end
end
