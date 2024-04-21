class CheckGitBranches < Baseline::Service
  def call
    check_uniqueness

    page = 1

    begin
      branches = External::Github.list_branches(page)

      break if branches.empty?

      branches
        .map { _1.fetch(:name) }
        .grep(/\A\d+\z/)
        .each do |compat_id|

        compat = Compat.find(compat_id)

        case
        when !compat.pending?
          External::Github.delete_branch(compat.id)
        when compat.checked_before?(1.week.ago)
          if Date.current > Date.new(2024, 6, 1)
            ReportError.call "remove this!"
          end
          if compat.invalid?
            compats = Compat.where(dependencies: compat.dependencies)
            if compats.size == RailsRelease.count && !compats.include?(compat)
              compat.destroy
              next
            end
          end

          compat.unchecked!
          External::Github.delete_branch(compat.id)
          Compats::Check.call_async compat
        end
      end

      page += 1
    end while page <= 10
  end
end
