require "rails_helper"

RSpec.describe Compats::Checks::EmptyDependenciesCheck, type: :service do
  let(:rails_release) { FactoryBot.create(:rails_release) }
  let(:compat) { Compat.new(status: :pending, rails_release: rails_release, dependencies: {}) }
  let(:check) { described_class.new(compat) }

  describe "#call" do
    context "when compat is pending and has no dependencies" do
      it "marks compat as compatible" do
        check.call

        expect(compat.status).to eq("compatible")
        expect(compat.status_determined_by).to eq("empty_dependencies")
        expect(compat).to be_checked
      end
    end

    context "when compat is not pending" do
      it "does not change the status" do
        compat.status = :incompatible

        expect do
          check.call
        end.not_to change { compat.status }
      end
    end

    context "when compat has dependencies" do
      it "does not mark compat as compatible" do
        compat.dependencies = {"colorize"=>"~> 0.8, >= 0.8.1", "require_all"=>"~> 1.1, >= 1.1.6"}

        check.call

        expect(compat.status).not_to eq(:compatible)
      end
    end

    context "when compat is already checked" do
      it "does not change the status" do
        compat.status = :incompatible
        compat.status_determined_by = "rails_gems"
        compat.checked!

        check.call

        expect(compat.status).to eq("incompatible")
      end
    end

    context "when compat has nil dependencies" do
      it "marks compat as compatible" do
        compat.dependencies = nil

        check.call

        expect(compat.status).to eq("compatible")
        expect(compat.status_determined_by).to eq("empty_dependencies")
        expect(compat).to be_checked
      end
    end
  end

  describe "#check!" do
    context "when compat is pending and has no dependencies" do
      it "marks compat as compatible and saves it" do
        expect(compat).to receive(:save!)

        check.check!

        expect(compat.status).to eq("compatible")
        expect(compat.status_determined_by).to eq("empty_dependencies")
        expect(compat).to be_checked
      end
    end

    context "when compat is not pending" do
      it "does not change the status and does not save it" do
        compat.status = :incompatible
        expect(compat).to receive(:save!)

        check.check!

        expect(compat.status).to eq("compatible")
      end
    end
  end
end