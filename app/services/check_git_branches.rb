class CheckGitBranches < Baseline::Service
  def call
    check_uniqueness

    page = 1

    loop do
      branches = External::Github.list_branches(page)

      break if branches.empty?

      branches
        .map { _1.fetch(:name) }
        .grep(/\A\d+\z/)
        .then { Compat.find(_1).reject(&:pending?) } # Use `.find` to make sure an error is raised unless all branches have a corresponding compat.
        .each do |compat|

        External::Github.delete_branch(compat.id)
      end

      page += 1
    end
  end
end
