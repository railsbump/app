require "fileutils"

# The purpose of this service is to check a compat, i.e. determine whether its set of dependencies is compatible with its Rails release or not. To do so, several approaches are taken, from least to most complex.
module Compats
  class Check < Baseline::Service
    CHECK_STRATEGIES = [
      Compats::Checks::EmptyDependenciesCheck,
      Compats::Checks::RailsGemsCheck,
      Compats::Checks::DependencySubsetsCheck,
      Compats::Checks::BundlerGithubCheck
    ]

    attr_accessor :compat

    # This method checks a compat by calling all check strategies. It only does checks on pending compats.
    #
    # If any of them marks the compat as incompatible, the compat is marked as incompatible.
    #
    # If any of them mark the compat as compatible, the compat is marked as compatible.
    #
    # @param [Compat] compat The compat to check
    def call(compat)
      check_uniqueness on_error: :return

      if compat.checked?
        raise Error, "Compat is already checked."
      end

      CHECK_STRATEGIES.each do |klass|
        klass.new(compat).call
      end
    end

    # This method checks a compat by calling all check strategies. It doesn't care about the compat's current status.
    # It will override the current status.
    #
    # If any of them marks the compat as incompatible, the compat is marked as incompatible.
    #
    # If any of them mark the compat as compatible, the compat is marked as compatible.
    #
    # @param [Compat] compat The compat to check
    def check!(compat)
      CHECK_STRATEGIES.each do |klass|
        klass.new(compat).check!
      end
    end

    private

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
  end
end
