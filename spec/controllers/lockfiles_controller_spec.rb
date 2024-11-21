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
  end

  describe "GET #show" do
    before { lockfile.save }

    it "returns a success response" do
      get :show, params: { id: lockfile.to_param }
      expect(response).to be_successful
    end
  end
end