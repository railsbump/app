require 'rails_helper'

RSpec.describe LockfilesController, type: :controller, vcr: { record: :once } do
  let(:lockfile) { FactoryBot.build(:lockfile) }

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Lockfile" do
        expect do
          post :create, params: { lockfile: { content: lockfile.content } }
        end.to change(Lockfile, :count).by(1)

        expect(response).to redirect_to(Lockfile.last)
      end

      context "and Gemfile.lock content was already submitted in the past" do
        it "redirects to the existing lockfile" do
          expect do
            post :create, params: { lockfile: { content: lockfile.content } }
          end.to change(Lockfile, :count).by(1)

          expect(response).to redirect_to(Lockfile.last)

          expect do
            post :create, params: { lockfile: { content: lockfile.content } }
          end.not_to change(Lockfile, :count)

          expect(response).to redirect_to(Lockfile.last)
        end
      end

      context "and Gemfile.lock content has local paths" do
        it "creates a new Lockfile" do
          content = File.read("spec/fixtures/Gemfile.local.lock")

          expect do
            post :create, params: { lockfile: { content: content } }
          end.to change(Lockfile, :count).by(1)

          expect(response).to redirect_to(Lockfile.last)
        end

        it "creates n inaccessible gemmies in the database" do
          content = File.read("spec/fixtures/Gemfile.local.lock")

          expect do
            post :create, params: { lockfile: { content: content } }
          end.to change(InaccessibleGemmy, :count).by(2)

          lockfile = Lockfile.last

          expect(lockfile.inaccessible_gemmies.map(&:name)).to match_array(["gitlab-specific-attr-ancrypted", "openbao_client"])
        end
      end
    end

    context "when lockfile already exists" do
      before do
        allow(Lockfiles::Create).to receive(:call).and_raise(Lockfiles::Create::AlreadyExists.new(lockfile))
      end

      it "redirects to the existing lockfile" do
        post :create, params: { lockfile: { content: 'existing lockfile content' } }
        expect(response).to redirect_to(lockfile)
      end
    end

    context "when a general error occurs" do
      it "renders the new template with an error message" do
        post :create, params: { lockfile: { content: 'invalid lockfile content' } }

        expect(response).to redirect_to(new_lockfile_path)
        expect(flash[:alert]).to eq("Gemmies can't be blank. Content does not look like a valid lockfile.. Content No gems found in content.")
      end
    end

    context "with the new check flow", new_check_flow: true, vcr: false do
      let(:rails_content) do
        <<~LOCK
          GEM
            remote: https://rubygems.org/
            specs:
              rails (7.1.3)
              puma (6.4.0)

          PLATFORMS
            ruby

          DEPENDENCIES
            rails (= 7.1.3)
            puma

          BUNDLED WITH
             2.4.10
        LOCK
      end

      let(:no_rails_content) do
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

      context "when a next Rails release is available" do
        before { FactoryBot.create(:rails_release, version: "7.2") }

        it "creates the lockfile and redirects to its show page" do
          expect do
            post :create, params: { lockfile: { content: rails_content } }
          end.to change(Lockfile, :count).by(1)

          expect(response).to redirect_to(Lockfile.last)
        end
      end

      context "when the lockfile is already on the latest known Rails" do
        before { FactoryBot.create(:rails_release, version: "7.1") }

        it "redirects back to the form with an alert and does not persist the lockfile" do
          expect do
            post :create, params: { lockfile: { content: rails_content } }
          end.not_to change(Lockfile, :count)

          expect(response).to redirect_to(new_lockfile_path)
          expect(flash[:alert]).to be_present
          expect(flash[:alert]).to match(/latest/i)
        end
      end

      context "when the lockfile has no Rails dependency" do
        it "redirects back to the form with an alert and does not persist the lockfile" do
          expect do
            post :create, params: { lockfile: { content: no_rails_content } }
          end.not_to change(Lockfile, :count)

          expect(response).to redirect_to(new_lockfile_path)
          expect(flash[:alert]).to be_present
          expect(flash[:alert]).to match(/Rails/i)
        end
      end

      context "when the content is not a valid lockfile" do
        it "redirects back to the form with an alert and does not persist the lockfile" do
          expect do
            post :create, params: { lockfile: { content: "not a lockfile" } }
          end.not_to change(Lockfile, :count)

          expect(response).to redirect_to(new_lockfile_path)
          expect(flash[:alert]).to be_present
        end
      end
    end
  end

  describe "GET #show" do
    before { lockfile.save }

    it "returns a success response" do
      get :show, params: { id: lockfile.to_param }
      expect(response).to be_successful
    end
  end
end