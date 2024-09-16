require "fileutils"

# The purpose of this service is to check a compat, i.e. determine whether its set of dependencies is compatible with its Rails release or not. To do so, several approaches are taken, from least to most complex.
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

    attr_accessor :compat

    def call(compat)
      check_uniqueness on_error: :return

      if compat.checked?
        raise Error, "Compat is already checked."
      end

      @compat = compat

      call_all_private_methods_without_args

      compat.checked!
    end

    private

      # This method checks for the simplest case: if the compat has no dependencies, it's marked as compatible.
      def check_empty_dependencies
        return unless @compat.pending?

        if @compat.dependencies.blank?
          @compat.status               = :compatible
          @compat.status_determined_by = "empty_dependencies"
        end
      end

      # This method checks if the dependencies include any Rail gems, and if so, if any of them have a different version than the compat's Rails version. If that's the case, the compat is marked as incompatible.
      def check_rails_gems
        return unless @compat.pending?

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

      # This method checks if any other compats exist, that are marked as incompatible and have a subset of the compat's dependencies. If so, the compat must be incompatible and is marked as such.
      def check_dependency_subsets
        return unless @compat.pending? && (2..10).cover?(@compat.dependencies.size)

        subsets = (1..@compat.dependencies.size - 1).flat_map do |count|
          @compat.dependencies.keys.combination(count).map { @compat.dependencies.slice *_1 }
        end

        subsets.in_groups_of(100, false).each do |group|
          if @compat.rails_release.compats.where("dependencies::jsonb = ?", group.to_json).incompatible.any?
            @compat.status               = :incompatible
            @compat.status_determined_by = "dependency_subsets"
            return
          end
        end
      end

      # This method checks if any other compats exist, that are marked as compatible and have a superset of the compat's dependencies. If so, the compat must be compatible and is marked as such.
      def check_dependency_supersets
        # return unless @compat.pending?
        #
        # TODO: How to convert `.contains` to SQLite?
        # if @compat.rails_release.compats.where.contains(dependencies: @compat.dependencies).compatible.any?
        #   @compat.status               = :compatible
        #   @compat.status_determined_by = "dependency_supersets"
        #   return
        # end
      end

      # This method checks a compat by actually attempting to install the compat's dependencies with the compat's Rails version locally. If the installation fails, the compat is marked as incompatible. If it succeeds, it is marked as compatible. If any of the dependencies have native extensions that cannot be built, the compat is marked as inconclusive.
      # def check_with_bundler_locally
      #   return unless @compat.pending? && @compat.check_locally

      #   dir  = Rails.root.join("tmp", "compats")
      #   file = dir.join(@compat.id.to_s)
      #   FileUtils.mkdir_p dir

      #   begin
      #     deps_with_rails = @compat.dependencies.dup.tap {
      #       _1["rails"] = [
      #         _1["rails"],
      #         "#{@compat.rails_release.version.approximate_recommendation}.0"
      #       ].compact
      #        .join(", ")
      #     }
      #     gemfile_deps = deps_with_rails.map {
      #       quoted_versions = _2.split(/\s*,\s*/).map { |d| "'#{d}'" }
      #       "gem '#{_1}', #{quoted_versions.join(", ")}, require: false"
      #     }
      #     File.write file, <<~SCRIPT
      #       #!/usr/bin/env ruby

      #       require "bundler/inline"

      #       gemfile true do
      #         source "https://rubygems.org"
      #         ruby "#{@compat.rails_release.compatible_ruby_version}"
      #         #{gemfile_deps.join("\n")}
      #       end
      #     SCRIPT
      #     File.chmod 0755, file

      #     stderr, stdout = Bundler.with_unbundled_env do
      #       Open3.popen3 file.to_s do
      #         # For some reason, the order matters: readlines must be called on stderr first. 🤷‍♂️
      #         [_3, _2].map do |io|
      #           io.readlines.map(&:strip)
      #         end
      #       end
      #     end
      #   ensure
      #     if File.exist?(file)
      #       FileUtils.rm_rf file
      #     end
      #   end

      #   stdout.each do |line|
      #     if match = line.match(/\AInstalling (?<name>\S+) (?<version>\S+)\z/)
      #       # TODO: uninstall gem again
      #     end
      #   end

      #   case
      #   when stderr.empty?
      #     @compat.status = :compatible
      #   when stderr.any?(/ERROR: Failed to build gem native extension/)
      #     @compat.status = :inconclusive
      #   when stderr.any?(/You have already activated/)
      #     return
      #   else
      #     unless stderr[0].end_with?("Could not find compatible versions (Bundler::SolveFailure)") &&
      #       stderr.exclude?("Your bundle requires a different version of Bundler than the one you're running.")

      #       raise Error, "Unexpected stderr: #{stderr.join("\n")}"
      #     end

      #     @compat.status = :incompatible
      #   end

      #   require "byebug"; byebug
      #   @compat.status_determined_by = "bundler_local"
      # end

      # This method checks a compat by creating a new branch in the "checker" repository, adding a Gemfile with the compat's dependencies and pushing it to GitHub. A GitHub Actions workflow is then triggered in the "checker" repo, which tries to run `bundler lock` to resolve the dependencies. Afterwards, GitHub sends a notification to the "github_notifications" API endpoint, which creates a new GithubNotification and processes it in `GithubNotifications::Process`.
      def check_with_bundler_github
        return unless @compat.pending? && Rails.env.production?

        dependencies = @compat
          .dependencies
          .dup
          .transform_values {
            _1.split(/\s*,\s*/)
          }.then {
            _1["rails"] ||= []
            _1["rails"] << "#{@compat.rails_release.version.approximate_recommendation}.0"
          }

        External::Github.dispatch_workflow \
          "railsbump/checker",
          "check.yml",
          :main,
          compat_id:       @compat.id.to_s,
          ruby_version:    @compat.rails_release.compatible_ruby_version.to_s,
          bundler_version: @compat.rails_release.compatible_bundler_version.to_s,
          dependencies:    dependencies.to_json
      end
  end
end
