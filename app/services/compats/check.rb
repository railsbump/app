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
        check_dependencies_individually
        check_with_github
      ).each do |method|
        send method if @compat.compatible.nil?
      end

      compat.checked!
    end

    private

      def check_empty_dependencies
        if @compat.dependencies.blank?
          @compat.update! compatible: true
        end
      end

      def check_rails_gems
        @compat.dependencies.each do |gem_name, requirement|
          next unless RAILS_GEMS.include?(gem_name)
          requirement_unmet = requirement.split(/\s*,\s*/).any? do |r|
            !Gem::Requirement.new(r).satisfied_by?(@compat.rails_release.version)
          end
          if requirement_unmet
            @compat.update! compatible: false
            return
          end
        end
      end

      def check_dependencies_individually
        @compat.dependencies.each do |gem_name, requirement|
          if @compat.rails_release.compats.find_by(dependencies: { gem_name: requirement })&.incompatible?
            @compat.update! compatible: false
            return
          end
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
        end.unshift("source 'https://rubygems.org'")

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
