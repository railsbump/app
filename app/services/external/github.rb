require "octokit"

module External
  class Github < Baseline::ExternalService
    REPO = "railsbump/checker"

    def list_branches(page = 1)
      client.branches \
        REPO,
        per_page: 100,
        page:     page
    end

    def delete_branch(name)
      client.delete_branch \
        REPO,
        name
    rescue Octokit::UnprocessableEntity
      false
    end

    private

      def client
        @client ||= Octokit::Client.new(access_token: ENV.fetch("GITHUB_ACCESS_TOKEN"))
      end
  end
end
