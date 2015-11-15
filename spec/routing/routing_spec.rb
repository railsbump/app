require "rails_helper"

RSpec.describe "routes for app", :type => :routing do

  it 'routes #home' do
    expect(get: '/').to route_to('rubygems#index')
  end

  it 'routes #search' do
    expect(get: '/search').to route_to('rubygems#search')
  end

  context 'rubygems' do
    context 'invalid routes in rubygems' do

      it 'should not route to #destoy' do
        expect(delete: '/rubygems', id: '1').not_to be_routable
      end

      it 'should not route to #edit' do
        expect(delete: '/rubygems', id: '1').not_to be_routable
      end

      it 'should not route to #udpate' do
        expect(delete: '/rubygems', id: '1', rubugems: {}).not_to be_routable
      end
    end
  end
end
