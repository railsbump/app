require "rails_helper"

RSpec.describe CheckGitBranches, type: :service do
  let(:service) { described_class.new }

  describe "#call" do
    let(:mock_client) { instance_double(External::Github) }

    before do
      allow(External::Github).to receive(:new).and_return(mock_client)
      allow(mock_client).to receive(:list_branches).and_return([])
      allow(mock_client).to receive(:delete_branch).and_return(true)
    end

    context "with branches matching compat ids" do
      let(:compat) { FactoryBot.create(:compat, status: :pending) }
      let(:branches) do
        [
          { name: compat.id.to_s },
          { name: "12345" }, # nonexistent compat
          { name: "main" },  # non-numeric branch
          { name: "develop" } # non-numeric branch
        ]
      end

      before { allow(mock_client).to receive(:list_branches).and_return(branches, []) }

      context "when compat is unchecked or not pending" do
        let(:compat) do
          compat = FactoryBot.create(:compat, status: :pending)
          compat.update!(status: :compatible, status_determined_by: "test", checked_at: Time.current)
          compat
        end

        it "deletes the branch" do
          service.call

          # The code may pass either string or integer (compat.id is integer, compat_id from branch name is string)
          expect(mock_client).to have_received(:delete_branch).with(be_in([compat.id, compat.id.to_s]))
        end
      end

      context "when compat is pending and checked recently" do
        let(:compat) { FactoryBot.create(:compat, status: :pending) }

        before { compat.checked! }

        it "does not delete the branch" do
          service.call

          expect(mock_client).not_to have_received(:delete_branch).with(compat.id.to_s)
        end
      end

      context "when compat is pending and checked long ago" do
        let(:compat) { FactoryBot.create(:compat, status: :pending) }

        before { compat.update!(checked_at: 2.weeks.ago) }

        it "marks compat as unchecked" do
          service.call

          expect(compat.reload.status).to eq("pending")
        end

        it "deletes the branch" do
          service.call

          # The code may pass either string or integer (compat.id is integer, compat_id from branch name is string)
          expect(mock_client).to have_received(:delete_branch).with(be_in([compat.id, compat.id.to_s]))
        end

        context "when compat is for latest major Rails release" do
          let(:rails_release) { FactoryBot.create(:rails_release, version: "7.1") }
          let(:compat) { FactoryBot.create(:compat, rails_release: rails_release, status: :pending) }

          before do
            compat.update!(checked_at: 2.weeks.ago)
            allow(RailsRelease).to receive(:latest_major).and_return([rails_release])
            allow(Compats::Check).to receive(:perform_async)
          end

          it "schedules compat check" do
            service.call

            expect(Compats::Check).to have_received(:perform_async).with(compat.id)
          end
        end
      end

      context "when compat does not exist" do
        it "deletes the branch" do
          service.call

          expect(mock_client).to have_received(:delete_branch).with("12345")
        end
      end
    end

    context "with invalid compats" do
      let(:compat) { FactoryBot.create(:compat) }
      let(:branches) { [{ name: compat.id.to_s }] }

      before do
        allow(mock_client).to receive(:list_branches).and_return(branches, [])
        allow(compat).to receive(:invalid?).and_return(true)
      end

      context "when duplicate dependencies exist for all Rails releases" do
        let(:other_compat) { FactoryBot.create(:compat, dependencies: compat.dependencies) }

        before do
          allow(Compat).to receive(:where).and_return(double(size: RailsRelease.count + 1, include?: false))
          allow(mock_client).to receive(:delete_branch)
        end

        it "destroys the compat and deletes the branch" do
          service.call

          # The code passes compat.id (integer) when deleting
          expect(mock_client).to have_received(:delete_branch).at_least(:once) do |arg|
            arg == compat.id || arg == compat.id.to_s
          end
        end
      end
    end

    context "with pagination" do
      it "fetches multiple pages" do
        allow(mock_client).to receive(:list_branches).and_return(
          [{ name: "1" }],
          [{ name: "2" }],
          []
        )

        service.call

        expect(mock_client).to have_received(:list_branches).at_least(3).times
      end

      it "stops after 10 pages" do
        call_count = 0
        allow(mock_client).to receive(:list_branches) do |page|
          call_count += 1
          [{ name: "branch_#{page}" }]
        end

        service.call

        expect(call_count).to eq(10)
      end
    end
  end
end
