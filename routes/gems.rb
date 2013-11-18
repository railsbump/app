class Gems < Cuba
  define do
    on 'search', param('query') do |query|
      render 'gems', gems: Rubygem.search(query)
    end

    on 'new' do
      render 'gems/new', gem: CreateRubygem.new({})
    end

    on post do
      on param('gem') do |params|
        gem = CreateRubygem.new params

        on gem.valid? do
          Rubygem.create gem.attributes

          res.redirect '/gems'
        end

        on default do
          render 'gems/new', gem: gem
        end
      end

      on default do
        not_found
      end
    end

    on default do
      render 'gems', gems: Rubygem.recent
    end
  end
end
