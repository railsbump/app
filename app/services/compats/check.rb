require 'fileutils'

module Compats
  class Check < Services::Base
    def call(compat)
      check_uniqueness

      if compat.checked?
        raise Error, 'Compat is already checked.'
      end

      case
      when compat.dependencies.blank?
        compat.update! compatible: true
      when Rails.env.production?
        @compat = compat
        check
      end

      compat.checked!
    end

    private

      def check
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
                             notifications:
                               webhooks: #{Rails.application.routes.url_helpers.api_travis_notifications_url}
                           CONTENT
          'Gemfile'     => <<~CONTENT,
                             source 'https://rubygems.org'

                             #{gemfile_dependencies.join("\n")}
                           CONTENT
          'Rakefile'    => 'task :default'
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
