module Gemfiles
  class Create < Services::Base
    class AlreadyExists < Error
      attr_reader :gemfile

      def initialize(gemfile)
        super nil

        @gemfile = gemfile
      end
    end

    def call(content)
      gemfile = Gemfile.new(content: content)

      if content.present?
        bundler   = Bundler::Dsl.new
        gem_names = bundler.eval_gemfile('', content).map(&:name).sort - %w(rails)

        if gem_names.none?
          raise Error, 'No gems found in content.'
        end

        gemfile.slug = Digest::SHA1.hexdigest(gem_names.join('#'))

        if existing_gemfile = Gemfile.find_by(slug: gemfile.slug)
          raise AlreadyExists.new(existing_gemfile)
        end

        gem_names.each do |gem_name|
          gemmy = Gemmy.find_by(name: gem_name) || Gemmies::Create.call(gem_name)
          gemfile.gemmies << gemmy
        end
      end

      gemfile.tap(&:save!)
    end
  end
end
