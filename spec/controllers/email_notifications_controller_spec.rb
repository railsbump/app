require "rails_helper"

RSpec.describe EmailNotificationsController, type: :controller do
  describe "POST #create" do
    let(:gemmy) { FactoryBot.create(:gemmy) }
    let(:valid_params) do
      {
        email_notification: {
          email: "test@example.com",
          notifiable_gid: gemmy.to_global_id.to_s
        }
      }
    end

    before do
      # Clean up any existing email notifications in Redis for test isolation
      allow(Kredis.redis).to receive(:keys).and_return([])
      allow(Kredis.redis).to receive(:sadd).and_return(true)
    end

    context "with valid parameters" do
      it "creates an email notification" do
        expect(Kredis.redis).to receive(:sadd).with(
          "email_notifications:#{gemmy.to_global_id}",
          "test@example.com"
        )
        post :create, params: valid_params, format: :turbo_stream
      end

      it "returns 200 OK" do
        post :create, params: valid_params, format: :turbo_stream
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid parameters" do
      context "missing email" do
        let(:invalid_params) do
          {
            email_notification: {
              notifiable_gid: gemmy.to_global_id.to_s
            }
          }
        end

        it "does not create an email notification" do
          expect(Kredis.redis).not_to receive(:sadd)
          post :create, params: invalid_params
        end

        it "renders the form partial with unprocessable entity status" do
          post :create, params: invalid_params
          expect(response).to render_template(partial: "email_notifications/_form")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "invalid email format" do
        let(:invalid_params) do
          {
            email_notification: {
              email: "invalid-email",
              notifiable_gid: gemmy.to_global_id.to_s
            }
          }
        end

        it "does not create an email notification" do
          expect(Kredis.redis).not_to receive(:sadd)
          post :create, params: invalid_params
        end
      end
    end
  end
end
