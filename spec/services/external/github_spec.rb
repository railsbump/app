require "rails_helper"

RSpec.describe External::Github, type: :service do
  let(:service) { described_class.new }
  let(:mock_client) { instance_double(Octokit::Client) }

  before do
    allow(Octokit::Client).to receive(:new).and_return(mock_client)
  end

  describe "#list_branches" do
    let(:branches) { [{ name: "main" }, { name: "develop" }] }

    it "calls client.branches with correct parameters" do
      expect(mock_client).to receive(:branches).with(
        External::Github::REPO,
        per_page: 100,
        page: 1
      ).and_return(branches)

      result = service.list_branches

      expect(result).to eq(branches)
    end

    it "passes page parameter correctly" do
      expect(mock_client).to receive(:branches).with(
        External::Github::REPO,
        per_page: 100,
        page: 2
      ).and_return([])

      service.list_branches(2)
    end
  end

  describe "#delete_branch" do
    context "when branch exists" do
      it "deletes the branch successfully" do
        expect(mock_client).to receive(:delete_branch).with(
          External::Github::REPO,
          "branch_name"
        ).and_return(true)

        result = service.delete_branch("branch_name")

        expect(result).to be true
      end
    end

    context "when branch does not exist" do
      it "returns false on UnprocessableEntity error" do
        expect(mock_client).to receive(:delete_branch).with(
          External::Github::REPO,
          "nonexistent"
        ).and_raise(Octokit::UnprocessableEntity)

        result = service.delete_branch("nonexistent")

        expect(result).to be false
      end
    end
  end

  describe "client initialization" do
    it "uses GITHUB_ACCESS_TOKEN from environment" do
      allow(ENV).to receive(:fetch).with("GITHUB_ACCESS_TOKEN").and_return("token123")
      allow(mock_client).to receive(:branches).and_return([])

      expect(Octokit::Client).to receive(:new).with(access_token: "token123")

      described_class.new.list_branches
    end
  end
end
