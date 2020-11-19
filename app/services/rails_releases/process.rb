module RailsReleases
  class Process < Services::Base
    def call(rails_release)
      # We only need to process each unique set of dependencies once.
      # Is there a way to get to them without resorting to `pluck`, which would load them all into memory?
      processed_dependencies = []
      Compat.where.not(rails_release: rails_release).find_each do |compat|
        next if processed_dependencies.include?(compat.dependencies)
        rails_release.compats.where(dependencies: compat.dependencies).first_or_create!
        processed_dependencies << compat.dependencies
      end

      Compats::CheckAllUnchecked.call_async
    end
  end
end
