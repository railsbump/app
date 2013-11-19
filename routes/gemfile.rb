class Gemfile < Cuba
  plugin GemfileHelpers

  define do
    on get, root do
      render 'gemfile', gemfile: nil
    end

    on post, param('gemfile') do |gemfile|
      gems = GemfileParser.new(gemfile).gems

      on !gems.empty? do
        status = GemfileStatus.new gems

        on accept('application/json') do
          json GemfileStatusSerializer.new(status)
        end

        on default do
          render 'gemfile/status',
            registered: status.registered,
            unregistered: status.unregistered
        end
      end

      on default do
        render 'gemfile', gemfile: gemfile
      end
    end

    on default do
      not_found
    end
  end
end
