require "rails_helper"

RSpec.describe Compats::Check, type: :service do
  let(:compat) { instance_double("Compat", checked?: false, pending?: true, dependencies: {}, rails_release: rails_release, check_locally: false) }
  let(:rails_release) { instance_double("RailsRelease", version: Gem::Version.new("6.0"), compatible_ruby_version: "2.7.2", compatible_bundler_version: "2.1.4") }
  let(:service) { described_class.new }

  describe "#call" do
    context "when compat is already checked" do
      before { allow(compat).to receive(:checked?).and_return(true) }

      it "raises an error" do
        expect { service.call(compat) }.to raise_error(Compats::Check::Error, "Compat is already checked.")
      end
    end

    context "when compat is not checked" do
      before do
        allow(service).to receive(:call_all_private_methods_without_args)
        allow(compat).to receive(:checked!)
      end

      it "calls all private methods and marks compat as checked" do
        service.call(compat)

        expect(service).to have_received(:call_all_private_methods_without_args)
        expect(compat).to have_received(:checked!)
      end
    end
  end
end