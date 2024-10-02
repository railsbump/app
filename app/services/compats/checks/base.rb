module Compats::Checks
  class Base
    def initialize(compat)
      @compat = compat
    end

    def call
      raise NotImplementedError
    end

    def check!
      raise NotImplementedError
    end
  end
end