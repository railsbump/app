class Gems < Cuba
  define do
    on 'search', param('query') do |query|
      render 'gems', gems: Rubygem.search(query, 20)
    end

    on 'new' do
      render 'gems/new', gem: Rubygem.new
    end

    on post do
      on param('gem') do |params|

      end

      on default do
        not_found
      end
    end

    on default do
      render 'gems', gems: Rubygem.recent(20)
    end
  end
end
