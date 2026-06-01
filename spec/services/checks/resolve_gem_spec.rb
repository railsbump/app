require "rails_helper"

RSpec.describe Checks::ResolveGem, type: :job, new_check_flow: true do
  let(:lockfile_check) { FactoryBot.create(:lockfile_check) }
  let(:gem_check) { FactoryBot.create(:gem_check, lockfile_check: lockfile_check, gem_name: "puma", status: "pending") }

  describe "#perform" do
    before do
      allow_any_instance_of(GemCheck).to receive(:perform!) do |gc|
        gc.update!(status: "complete", result: "compatible")
      end
    end

    it "resolves the gem check" do
      described_class.new.perform(gem_check.id)

      expect(gem_check.reload.status).to eq("complete")
    end

    it "marks the lockfile check complete once no gem checks remain pending" do
      described_class.new.perform(gem_check.id)

      expect(lockfile_check.reload.status).to eq("complete")
    end

    it "leaves the lockfile check pending while other gem checks are still pending" do
      FactoryBot.create(:gem_check, lockfile_check: lockfile_check, gem_name: "rack", status: "pending")

      described_class.new.perform(gem_check.id)

      expect(lockfile_check.reload.status).to eq("pending")
    end

    it "broadcasts the updated checks to the lockfile's stream" do
      stream = "#{lockfile_check.lockfile.to_gid_param}:gem_checks"

      expect do
        described_class.new.perform(gem_check.id)
      end.to have_broadcasted_to(stream)
    end
  end

  describe "retries exhausted" do
    subject(:run_exhausted) do
      described_class.sidekiq_retries_exhausted_block.call(
        { "args" => [gem_check.id] }, StandardError.new("boom")
      )
    end

    it "marks the unresolved gem check failed" do
      run_exhausted

      expect(gem_check.reload.status).to eq("failed")
    end

    it "completes the lockfile check once the failed gem is its last pending one" do
      run_exhausted

      expect(lockfile_check.reload.status).to eq("complete")
    end

    it "leaves the lockfile check pending while other gem checks are still pending" do
      FactoryBot.create(:gem_check, lockfile_check: lockfile_check, gem_name: "rack", status: "pending")

      run_exhausted

      expect(lockfile_check.reload.status).to eq("pending")
    end

    it "broadcasts the failure so the page leaves the spinner" do
      stream = "#{lockfile_check.lockfile.to_gid_param}:gem_checks"

      expect { run_exhausted }.to have_broadcasted_to(stream)
    end

    it "does nothing when the gem check no longer exists" do
      gem_check.destroy

      expect { run_exhausted }.not_to raise_error
    end
  end
end
