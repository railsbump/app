require "rails_helper"

RSpec.describe GemmiesController, type: :controller do
  describe "create", vcr: { record: :once } do
    context "when the gemmy params are valid" do
      it "redirects to the new gemmy page" do
        post :create, params: { gemmy: { name: "next_rails" } }
  
        expect(response).to redirect_to(gemmy_path(Gemmy.find_by(name: "next_rails")))
      end

      it "creates a record in the database" do
        expect do
          post :create, params: { gemmy: { name: "next_rails" } }
        end.to change(Gemmy, :count).by(1)
      end

      context "when the gemmy params are invalid" do
        it "renders the new gemmy page" do
          post :create, params: { gemmy: { name: "" } }
  
          expect(response).to render_template(:new)
        end

        it "does not create a record in the database" do
          expect do
            post :create, params: { gemmy: { name: "" } }
          end.not_to change(Gemmy, :count)
        end
      end
    end
  end
end