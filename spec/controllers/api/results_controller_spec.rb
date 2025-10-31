require 'rails_helper'

RSpec.describe API::ResultsController, type: :controller do
  let(:api_key) { FactoryBot.create(:api_key) }
  let(:rails_release) { FactoryBot.create(:rails_release) }
  let(:compat) { FactoryBot.create(:compat, rails_release: rails_release, status: :pending) }
  let(:headers) { { 'RAILS-BUMP-API-KEY' => api_key.key } }

  describe "POST #create" do
    context "with valid dependencies and result is successful" do
      it "updates the compat and returns ok" do
        request.headers.merge!(headers)

        post :create, params: {
          rails_version: rails_release.version,
          compat_id: compat.id,
          dependencies: compat.dependencies,
          result: {
            success: true,
            strategy: 'some_strategy'
          }
        }

        expect(compat.reload.status).to eq('compatible')
        expect(response).to have_http_status(:ok)
      end
    end

    context "with valid dependencies and result is unsuccessful" do
      it "updates the compat and returns ok" do
        request.headers.merge!(headers)

        post :create, params: {
          rails_version: rails_release.version,
          compat_id: compat.id,
          dependencies: compat.dependencies,
          result: {
            success: false,
            strategy: 'some_strategy'
          }
        }

        expect(compat.reload.status).to eq('incompatible')
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid dependencies" do
      it "returns unprocessable entity" do
        request.headers.merge!(headers)
        post :create, params: {
          rails_version: rails_release.version,
          compat_id: compat.id,
          dependencies: { invalid: 'dependency' },
          result: 'some_result'
        }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with invalid API key" do
      it "returns unauthorized" do
        request.headers.merge!({ 'RAILS-BUMP-API-KEY' => '' })
        post :create, params: {
        rails_version: rails_release.version,
          compat_id: compat.id,
          dependencies: compat.dependencies,
          result: 'some_result'
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "if result processing fails" do
      it "returns unprocessable entity" do
        allow_any_instance_of(Compat).to receive(:process_result).and_return(false)

        request.headers.merge!(headers)

        post :create, params: {
          rails_version: rails_release.version,
          compat_id: compat.id,
          dependencies: compat.dependencies,
          result: 'some_result'
        }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
