module Compats::Checks

  # This method checks a compat by dispatching the check_bundler workflow.
  class BundlerGithubCheck < Base
    def call
      return unless @compat.pending? && Rails.env.production?

      # Initialize the Octokit client with your GitHub token
      client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])

      # Define the repository, workflow file, and branch
      repo = 'railsbump/checker'
      workflow_id = 'check_bundler.yml'
      ref = 'main'

      # Define the inputs for the workflow
      inputs = {
        rails_version: @compat.rails_release.version.to_s,
        ruby_version: @compat.rails_release.compatible_ruby_version.to_s,
        bundler_version: @compat.rails_release.compatible_bundler_version.to_s,
        dependencies: JSON::dump(@compat.dependencies),
        compat_id: @compat.id.to_s
      }

      # Trigger the workflow dispatch event
      client.workflow_dispatch(repo, workflow_id, ref, inputs: inputs)
    end
  end
end