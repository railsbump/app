require "rails_helper"

RSpec.describe RailsReleasesHelper, type: :helper do
  describe "#head_title" do
    context "when @gemmy is not set" do
      it "calls super" do
        expect(helper.head_title).to eq("RailsBump.org: Rails Compatibility Checker Tool")
      end
    end

    context "when @gemmy is set" do
      let(:gemmy) { FactoryBot.create(:gemmy, name: "test_gem") }

      context "when @rails_release is set" do
        let(:rails_release) { FactoryBot.create(:rails_release, version: "7.1") }

        before do
          helper.instance_variable_set(:@gemmy, gemmy)
          helper.instance_variable_set(:@rails_release, rails_release)
        end

        it "returns title with gemmy and rails_release" do
          expect(helper.head_title).to eq("#{gemmy} gem: Compatibility with #{rails_release}")
        end
      end

      context "when @rails_release is not set" do
        before do
          FactoryBot.create(:rails_release, version: "7.0")
          FactoryBot.create(:rails_release, version: "7.1")
          helper.instance_variable_set(:@gemmy, gemmy)
        end

        it "returns title with gemmy and Rails version range" do
          result = helper.head_title
          expect(result).to include("#{gemmy} gem")
          expect(result).to include("Compatibility with Rails")
          expect(result).to include("7.0")
          expect(result).to include("7.1")
        end
      end
    end
  end

  describe "#meta_description" do
    context "when @gemmy is not set" do
      it "calls super" do
        expect(description = helper.meta_description).to include("RailsBump")
        expect(description).to include("compatibility")
      end
    end

    context "when @gemmy is set" do
      let(:gemmy) { FactoryBot.create(:gemmy, name: "test_gem") }

      context "when @rails_release is set" do
        let(:rails_release) { FactoryBot.create(:rails_release, version: "7.1") }

        before do
          helper.instance_variable_set(:@gemmy, gemmy)
          helper.instance_variable_set(:@rails_release, rails_release)
        end

        it "returns description with gemmy and rails_release" do
          result = helper.meta_description
          expect(result).to include(gemmy.name)
          expect(result).to include(rails_release.to_s)
          expect(result).to include("compatible")
        end
      end

      context "when @rails_release is not set" do
        before do
          FactoryBot.create(:rails_release, version: "7.0")
          FactoryBot.create(:rails_release, version: "7.1")
          helper.instance_variable_set(:@gemmy, gemmy)
        end

        it "returns description with gemmy and Rails version range" do
          result = helper.meta_description
          expect(result).to include(gemmy.name)
          expect(result).to include("Rails")
          expect(result).to include("7.0")
          expect(result).to include("7.1")
          expect(result).to include("compatibility")
        end
      end
    end
  end
end
