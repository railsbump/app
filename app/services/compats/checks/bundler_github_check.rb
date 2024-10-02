module Compats::Checks

  # This method checks a compat by dispatching the check_bundler workflow.
  class BundlerGithubCheck < Base
    # Define the repository, workflow file, and branch
    GITHUB_REPO = 'railsbump/checker'
    GITHUB_WORKFLOW = 'check_bundler.yml'
    GITHUB_REF = 'main'

    def call
      return unless @compat.pending? && Rails.env.production?

      check!
    end

    def check!
      # Initialize the Octokit client with your GitHub token
      client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])

      # Trigger the workflow dispatch event
      client.workflow_dispatch(GITHUB_REPO, GITHUB_WORKFLOW, GITHUB_REF, inputs: inputs)
    end

    private

    # Define the inputs for the workflow
    def inputs
      {
        rails_version: @compat.rails_release.version.to_s,
        ruby_version: @compat.rails_release.minimum_ruby_version.to_s,
        bundler_version: @compat.rails_release.minimum_bundler_version.to_s,
        dependencies: JSON::dump(@compat.dependencies),
        compat_id: @compat.id.to_s
      }
    end
  end
end