require 'fileutils'

module Compats
  class Check < Services::Base
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
        raise Error, 'Compat is already checked.'
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
          @compat.update! compatible: true, compatible_reason: 'empty_dependencies'
        end
      end

      def check_rails_gems
        @compat.dependencies.each do |gem_name, requirement|
          next unless RAILS_GEMS.include?(gem_name)
          requirement_unmet = requirement.split(/\s*,\s*/).any? do |r|
            !Gem::Requirement.new(r).satisfied_by?(@compat.rails_release.version)
          end
          if requirement_unmet
            @compat.update! compatible: false, compatible_reason: 'rails_gems'
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
            @compat.update! compatible: false, compatible_reason: 'dependency_subsets'
            return
          end
        end
      end

      def check_dependency_supersets
        if @compat.rails_release.compats.where.contains(dependencies: @compat.dependencies).compatible.any?
          @compat.update! compatible: true, compatible_reason: 'dependency_supersets'
          return
        end
      end

      def check_with_github
        return unless Rails.env.production?

        branch_name = @compat.id.to_s

        git = CheckOutGitRepo.call

        git.branches.select { _1.name == branch_name }.each do |branch|
          if branch.remote
            git.push 'origin', branch.name, delete: true
          else
            branch.delete
          end
        end

        git.branch(branch_name).checkout

        dependencies = @compat.dependencies.dup
        dependencies.transform_values! do |contraints|
          contraints.split(/\s*,\s*/)
        end
        dependencies['rails'] ||= []
        dependencies['rails'] << "= #{@compat.rails_release.version}"

        gemfile_content = dependencies.map do |gem, constraints_group|
          "gem '#{gem}', #{constraints_group.map { "'#{_1}'" }.join(', ')}"
        end.unshift("source 'https://rubygems.org'").join("\n")

        File.write File.join(git.dir.path, 'Gemfile'), gemfile_content

        git.add 'Gemfile'
        git.commit "Test #{@compat}"
        git.push 'origin', branch_name
      ensure
        if git && File.exist?(git.dir.path)
          FileUtils.rm_rf git.dir.path
        end
      end
  end
end
