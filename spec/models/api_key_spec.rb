require 'rails_helper'

RSpec.describe APIKey, type: :model do
  describe "#valid?" do
    let(:valid_attributes) { { name: "Valid API Key", key: "a" * 64 } }

    it "is valid with valid attributes" do
      api_key = APIKey.new(valid_attributes)
      expect(api_key).to be_valid
    end

    it "is invalid without a name" do
      api_key = APIKey.new(valid_attributes.except(:name))
      expect(api_key).not_to be_valid
      expect(api_key.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a key" do
      api_key = APIKey.new(valid_attributes.except(:key))
      expect(api_key).not_to be_valid
      expect(api_key.errors[:key]).to include("can't be blank")
    end

    it "is invalid with a duplicate name" do
      APIKey.create!(valid_attributes)
      api_key = APIKey.new(valid_attributes)
      expect(api_key).not_to be_valid
      expect(api_key.errors[:name]).to include("has already been taken")
    end

    it "is invalid with a duplicate key" do
      APIKey.create!(valid_attributes)
      api_key = APIKey.new(valid_attributes)
      expect(api_key).not_to be_valid
      expect(api_key.errors[:key]).to include("has already been taken")
    end

    it "is invalid with a name longer than 50 characters" do
      api_key = APIKey.new(valid_attributes.merge(name: "a" * 51))
      expect(api_key).not_to be_valid
      expect(api_key.errors[:name]).to include("is too long (maximum is 50 characters)")
    end

    it "is invalid with a key shorter than 64 characters" do
      api_key = APIKey.new(valid_attributes.merge(key: "a" * 63))
      expect(api_key).not_to be_valid
      expect(api_key.errors[:key]).to include("is too short (minimum is 64 characters)")
    end

    it "is invalid with a key longer than 255 characters" do
      api_key = APIKey.new(valid_attributes.merge(key: "a" * 256))
      expect(api_key).not_to be_valid
      expect(api_key.errors[:key]).to include("is too long (maximum is 255 characters)")
    end
  end
end
