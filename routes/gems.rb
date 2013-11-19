class Gems < Cuba
  define do
    on get, root do
      render 'gems', gems: Rubygem.recent
    end

    on 'search', param('name') do |name|
      render 'gems', gems: Rubygem.search_by_name(name)
    end

    on 'new' do
      render 'gems/new', gem: CreateRubygem.new(req.params)
    end

    on 'status/:status' do |status|
      gems = Rubygem.where status: status

      on !gems.empty? do
        render 'gems', gems: gems
      end

      on default do
        not_found
      end
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
      not_found
    end
  end
end
