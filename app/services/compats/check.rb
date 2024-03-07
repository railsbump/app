require "fileutils"

module Compats
  class Check < Baseline::Service
    RAILS_GEMS = %w(
      actioncable
      actionmailbox
      actionmailer
      actionpack
      actiontext
      actionview
      activejob
      activemodel
      activerecord
      activestorage
      activesupport
      rails
      railties
    )

    def call(compat)
      check_uniqueness

      if compat.checked?
        raise Error, "Compat is already checked."
      end

      @compat = compat

      %i(
        check_empty_dependencies
        check_rails_gems
        check_dependency_subsets
        check_dependency_supersets
        check_with_github
      ).each do |method|
        send method if @compat.pending?
      end

      compat.checked!
    end

    private

      def check_empty_dependencies
        if @compat.dependencies.blank?
          @compat.status               = :compatible
          @compat.status_determined_by = "empty_dependencies"
        end
      end

      def check_rails_gems
        @compat.dependencies.each do |gem_name, requirement|
          next unless RAILS_GEMS.include?(gem_name)
          requirement_unmet = requirement.split(/\s*,\s*/).any? do |r|
            !Gem::Requirement.new(r).satisfied_by?(@compat.rails_release.version)
          end
          if requirement_unmet
            @compat.status               = :incompatible
            @compat.status_determined_by = "rails_gems"
            return
          end
        end
      end

      def check_dependency_subsets
        return unless (2..10).cover?(@compat.dependencies.size)

        subsets = (1..@compat.dependencies.size - 1).flat_map do |count|
          @compat.dependencies.keys.combination(count).map { @compat.dependencies.slice *_1 }
        end

        subsets.in_groups_of(100, false).each do |group|
          if @compat.rails_release.compats.where(dependencies: group).incompatible.any?
            @compat.status               = :incompatible
            @compat.status_determined_by = "dependency_subsets"
            return
          end
        end
      end

      def check_dependency_supersets
        # TODO: How to convert `.contains` to SQLite?
        # if @compat.rails_release.compats.where.contains(dependencies: @compat.dependencies).compatible.any?
        #   @compat.status               = :compatible
        #   @compat.status_determined_by = "dependency_supersets"
        #   return
        # end
      end

      def check_with_github
        return unless Rails.env.production?

        branch_name = @compat.id.to_s

        CheckOutWorkerRepo.call do |git|
          git.branches.select { _1.name == branch_name }.each do |branch|
            if branch.remote
              git.push "origin", branch.name, delete: true
            else
              branch.delete
            end
          end

          git.branch(branch_name).checkout

          action_file = File.join(git.dir.path, ".github", "workflows", "ci.yml")
          action_content = File.read(action_file)
                               .gsub("RUBY_VERSION",    @compat.rails_release.compatible_ruby_version.to_s)
                               .gsub("BUNDLER_VERSION", @compat.rails_release.compatible_bundler_version.to_s)
          File.write action_file, action_content

          dependencies = @compat.dependencies.dup
          dependencies.transform_values! do |contraints|
            contraints.split(/\s*,\s*/)
          end
          dependencies["rails"] ||= []
          dependencies["rails"] << "#{@compat.rails_release.version.approximate_recommendation}.0"

          gemfile = File.join(git.dir.path, "Gemfile")
          gemfile_content = dependencies
            .map do |gem, constraints_group|
              "gem '#{gem}', #{constraints_group.map { "'#{_1}'" }.join(", ")}"
            end
            .unshift("source 'https://rubygems.org'")
            .join("\n")
          File.write gemfile, gemfile_content

          git.add [action_file, gemfile]
          git.commit @compat.to_s
          Octopoller.poll retries: 5 do
            git.push "origin", branch_name
          rescue Git::GitExecuteError
            :re_poll
          end
        end
      end
  end
end
