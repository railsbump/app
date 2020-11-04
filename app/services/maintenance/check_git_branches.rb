module Maintenance
  class CheckGitBranches < Services::Base
    def call
      check_uniqueness on_error: :return

      CheckOutGitRepo.call do |git|
        branches  = git.branches.remote.map(&:name).grep(/\A\d+\z/)
        threshold = 2.hours.ago

        branches.in_groups_of(100, false) do |group|
          done_compats = Compat.find(group).reject(&:pending?) # Use `.find` to make sure an error is raised
                                                               # unless all branches have a corresponding compat.

          if done_compats.any?
            git.push 'origin', done_compats.map(&:id), delete: true
          end
        end
      end
    end
  end
end
