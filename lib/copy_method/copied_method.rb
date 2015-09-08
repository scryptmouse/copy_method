module CopyMethod
  # Preserve constant lookups in copied methods.
  class CopiedMethod < Module
    # @!attribute [r] method_name
    # @return [Symbol]
    attr_reader :method_name

    # @!attribute [r] origin
    # @return [Symbol]
    attr_reader :origin

    attr_reader :singleton
    alias singleton? singleton

    # @param [Symbol] method_name
    # @param [Class] origin
    # @param [Boolean] singleton
    def initialize(origin, method_name, singleton: false)
      @method_name  = method_name
      @origin       = origin.to_s.to_sym
      @singleton    = singleton

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def const_missing(const_name)
          caller_method = caller_locations(1,1)[0].label

          super
        rescue NameError => e
          origin = ::#{origin}

          if caller_method == #{method_name.to_s.inspect} && origin.const_defined?(const_name)
            origin.const_get const_name
          else
            raise e
          end
        end
      RUBY
    end

    def inspect
      "CopyMethod::CopiedMethod(#{origin}#{method_symbol}#{method_name})"
    end

    private
    def method_symbol
      singleton? ? '.' : '#'
    end
  end
end
