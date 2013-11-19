class Gemfile < Cuba
  plugin GemfileHelpers

  define do
    on get do
      render 'gemfile', gemfile: nil
    end

    on post, param('gemfile') do |gemfile|
      gems = GemfileParser.new(gemfile).gems

      on !gems.empty? do
        status = GemfileStatus.new gems

        render 'gemfile/status',
          registered: status.registered,
          unregistered: status.unregistered
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
