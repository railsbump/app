require "octokit"

module External
  class Github < Baseline::ExternalService
    REPO = "railsbump/checker"

    add_method :list_branches do |page = 1|
      client.branches \
        REPO,
        per_page: 100,
        page:     page
    end

    add_method :delete_branch do |name|
      client.delete_branch \
        REPO,
        name
    end

    private

      def client
        @client ||= Octokit::Client.new(access_token: ENV.fetch("GITHUB_ACCESS_TOKEN"))
      end
  end
end
