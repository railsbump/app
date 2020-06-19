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
        check_with_travis
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
          if RAILS_GEMS.include?(gem_name) && !Gem::Requirement.new(requirement).satisfied_by?(@compat.rails_release.version)
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

      def check_with_travis
        return unless Rails.env.production?

        branch_name = @compat.id.to_s

        git = CheckOutGitRepo.call

        git.branches.select { |branch| branch.name == branch_name }.each do |branch|
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

        gemfile_dependencies = dependencies.map do |gem, constraints_group|
          "gem '#{gem}', #{constraints_group.map { |constraints| "'#{constraints}'" }.join(', ')}"
        end

        files = {
          '.travis.yml' => <<~CONTENT,
                             language: ruby
                             rvm:
                               - 2.6
                             install: bundle lock
                             script: ""
                             notifications:
                               webhooks: #{api_travis_notifications_url}
                           CONTENT
          'Gemfile'     => <<~CONTENT
                             source 'https://rubygems.org'

                             #{gemfile_dependencies.join("\n")}
                           CONTENT
        }

        files.each do |filename, content|
          File.write File.join(git.dir.path, filename), content
          git.add filename
        end

        git.commit "Test #{@compat}"

        git.push 'origin', branch_name
      ensure
        if git && File.exist?(git.dir.path)
          FileUtils.rm_rf git.dir.path
        end
      end
  end
end
