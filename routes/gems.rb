class Gems < Cuba
  define do
    on root do
      render 'gems', gems: Rubygem.recent
    end

    on 'search', param('name') do |name|
      render 'gems', gems: Rubygem.by_name(name)
    end

    on 'new' do
      render 'gems/new', gem: CreateRubygem.new({})
    end

    on 'status/:status' do |status|
      gems = Rubygem.by_status status

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
