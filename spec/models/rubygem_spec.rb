require 'rails_helper'

RSpec.describe Rubygem, type: :model do
  let(:name) { 'valid_gem' }
  let(:status_rails4) { 'ready' }
  let(:notes_rails4) { 'some note' }
  let(:miel) { nil }
  let(:gem) { FactoryGirl.build(:rubygem, name: name, status_rails4: status_rails4,
                                notes_rails4: notes_rails4, miel: miel) }

  describe 'for a valid ruby gem' do
    let(:json) {
      {"name"=>"devise",
     "downloads"=>13612445,
     "version"=>"3.5.2",
     "version_downloads"=>410281,
     "platform"=>"ruby",
     "authors"=>"José Valim, Carlos Antônio",
     "info"=>"Flexible authentication solution for Rails with Warden",
     "licenses"=>["MIT"],
     "metadata"=>{},
     "sha"=>"83a5f24351958d044360eb749dfd65d02383857b7f1b60a48b96410f454448f2",
     "project_uri"=>"https://rubygems.org/gems/devise",
     "gem_uri"=>"https://rubygems.org/gems/devise-3.5.2.gem",
     "homepage_uri"=>"https://github.com/plataformatec/devise",
     "wiki_uri"=>"",
     "documentation_uri"=>"http://github.com/plataformatec/devise",
     "mailing_list_uri"=>"http://groups.google.com/group/plataformatec-devise",
     "source_code_uri"=>"http://github.com/plataformatec/devise",
     "bug_tracker_uri"=>"",
     "dependencies"=>
      {"development"=>[],
         "runtime"=>
          [{"name"=>"bcrypt", "requirements"=>"~> 3.0"},
               {"name"=>"orm_adapter", "requirements"=>"~> 0.1"},
               {"name"=>"railties", "requirements"=>"< 5, >= 3.2.6"},
               {"name"=>"responders", "requirements"=>">= 0"},
               {"name"=>"thread_safe", "requirements"=>"~> 0.1"},
               {"name"=>"warden", "requirements"=>"~> 1.2.3"}]}}

    }
    before(:each) {
      allow(gem).to receive(:gem_exists_in_rubygem_dot_org).and_return(json)
    }

    context '#validations' do
      let(:status_rails4) { nil }
      let(:name) { nil }
      let(:notes_rails4) { nil }
      let(:miel) { 'abc' }

      before(:each) { gem.valid? }

      it 'should validate inputs' do
        expect(gem.errors[:name].size).to eq(1)
        expect(gem.errors[:status_rails4].size).to eq(2)
        expect(gem.errors[:notes_rails4].size).to eq(1)
        expect(gem.errors[:miel].size).to eq(1)
      end

      context 'with a valid status_rails4' do
        let!(:status_rails4) { 'ready' }

        it 'status_rails4 validation should pass' do
          expect(gem.errors[:status_rails4].size).to eq(0)
        end
      end

      context 'with an invalid status_rails4' do
        let!(:status_rails4) { 'invalid status_rails4' }

        it 'status_rails4 validation should fail' do
          expect(gem.errors[:status_rails4].size).to eq(1)
        end
      end
    end

    context '.scope' do
      let!(:gem_a) { FactoryGirl.create(:rubygem, name: 'a', status_rails4: 'ready', created_at: 2.days.ago) }
      let!(:gem_b) { FactoryGirl.create(:rubygem, name: 'b', status_rails4: 'unknown', created_at: DateTime.now) }

      it 'should oder gems by name' do
        expect(Rubygem.by_name.to_a).to eq([gem_a, gem_b])
      end

      it 'should oder by newest' do
        expect(Rubygem.newest.to_a).to eq([gem_b, gem_a])
      end

      it 'should select by status rails4' do
        expect(Rubygem.by_status('ready', 4).to_a).to eq([gem_a])
      end

    end
  end

  describe 'for invalid ruby gem' do
    let(:name) { Random.new_seed }

    it 'should raise error' do
      gem.valid?
      expect(gem.errors[:name].size).to eq(1)
    end

  end
end

