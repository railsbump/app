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

        unless compat = Compat.find_by(id: compat_id)
          External::Github.delete_branch(compat_id)
          next
        end

        if Date.current > Date.new(2024, 10, 1)
          ReportError.call "remove this when all old git branches are gone"
        end
        if compat.invalid?
          compats = Compat.where("dependencies::jsonb = ?", compat.dependencies.to_json)
          if compats.size == RailsRelease.count && !compats.include?(compat)
            compat.destroy
            External::Github.delete_branch(compat.id)
            next
          end
        end

        case
        when compat.unchecked? || !compat.pending?
          External::Github.delete_branch(compat.id)
        when compat.checked_before?(1.week.ago)
          compat.unchecked!
          External::Github.delete_branch(compat.id)

          if RailsRelease.latest_major.include?(compat.rails_release)
            Compats::Check.perform_async compat.id
          end
        end
      end

      page += 1
    end while page <= 10
  end
end
