require "rails_helper"

RSpec.describe ReportError, type: :service do
  describe ".call" do
    it "delegates to Baseline::ReportError" do
      expect(Baseline::ReportError).to receive(:call).with("test error")

      ReportError.call("test error")
    end

    it "handles error with additional context" do
      expect(Baseline::ReportError).to receive(:call).with("test error", { count: 5 })

      ReportError.call("test error", count: 5)
    end
  end
end

