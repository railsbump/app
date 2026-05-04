require "rails_helper"

RSpec.describe Lockfile::Inspection, type: :model, new_check_flow: true do
  def lockfile_content(rails_version: "7.1.3")
    <<~LOCK
      GEM
        remote: https://rubygems.org/
        specs:
          rails (#{rails_version})
          puma (6.4.0)

      PLATFORMS
        ruby

      DEPENDENCIES
        rails (= #{rails_version})
        puma

      BUNDLED WITH
         2.4.10
    LOCK
  end

  def content_without_rails
    <<~LOCK
      GEM
        remote: https://rubygems.org/
        specs:
          puma (6.4.0)

      PLATFORMS
        ruby

      DEPENDENCIES
        puma

      BUNDLED WITH
         2.4.10
    LOCK
  end

  describe ".call" do
    context "when the content does not look like a lockfile" do
      it "returns reason :invalid_content" do
        result = described_class.call("not a lockfile")

        expect(result.reason).to eq(:invalid_content)
        expect(result.message).to be_present
        expect(result.http_status).to eq(:unprocessable_content)
        expect(result.lockfile).to be_nil
      end
    end

    context "when the lockfile has no Rails dependency" do
      it "returns reason :no_rails_dependency" do
        result = described_class.call(content_without_rails)

        expect(result.reason).to eq(:no_rails_dependency)
        expect(result.message).to be_present
        expect(result.http_status).to eq(:unprocessable_content)
        expect(result.lockfile).to be_nil
      end
    end

    context "when the lockfile is already on the latest known Rails" do
      it "returns reason :up_to_date" do
        FactoryBot.create(:rails_release, version: "7.1")

        result = described_class.call(lockfile_content(rails_version: "7.1.3"))

        expect(result.reason).to eq(:up_to_date)
        expect(result.message).to be_present
        expect(result.http_status).to eq(:ok)
        expect(result.lockfile).to be_nil
      end
    end

    context "when there is a next Rails release available" do
      it "returns reason :runnable with an unsaved Lockfile" do
        FactoryBot.create(:rails_release, version: "7.2")

        result = described_class.call(lockfile_content(rails_version: "7.1.3"))

        expect(result.reason).to eq(:runnable)
        expect(result.http_status).to eq(:accepted)
        expect(result.lockfile).to be_a(Lockfile)
        expect(result.lockfile).not_to be_persisted
        expect(result.lockfile.content).to include("rails (7.1.3)")
      end
    end

    it "trims leading and trailing whitespace before inspecting" do
      result = described_class.call("\n\n  not a lockfile  \n")

      expect(result.reason).to eq(:invalid_content)
    end

    it "treats blank input as invalid content" do
      result = described_class.call("")

      expect(result.reason).to eq(:invalid_content)
    end

    it "treats model-level validation failures as invalid content" do
      FactoryBot.create(:rails_release, version: "7.2")
      allow_any_instance_of(Lockfile).to receive(:valid?).and_return(false)

      result = described_class.call(lockfile_content)

      expect(result.reason).to eq(:invalid_content)
    end

    it "treats Bundler parse errors as invalid content" do
      allow(Bundler::LockfileParser).to receive(:new).and_raise(Bundler::LockfileError, "boom")

      result = described_class.call(lockfile_content)

      expect(result.reason).to eq(:invalid_content)
    end
  end
end
