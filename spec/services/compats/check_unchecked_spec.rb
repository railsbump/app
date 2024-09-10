require "rails_helper"

RSpec.describe Compats::CheckUnchecked, type: :service do
  describe "do_call" do
    it "calls Compats::Check#call" do
      expect(Compats::Check).to receive(:call)

      release = FactoryBot.create :rails_release, version: "5.0"
      compat = FactoryBot.create :compat, rails_release: release
      
      Compats::CheckUnchecked.call
    end
  end
end