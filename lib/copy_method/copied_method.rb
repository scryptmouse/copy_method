module CopyMethod
  # Preserve constant lookups in copied methods.
  class CopiedMethod < Module
    # @!attribute [r] method_name
    # @return [Symbol]
    attr_reader :method_name

    # @!attribute [r] original_class
    # @return [Symbol]
    attr_reader :original_class

    attr_reader :singleton
    alias singleton? singleton

    # @param [Symbol] method_name
    # @param [Class] original_class
    # @param [Boolean] singleton
    def initialize(original_class, method_name, singleton: false)
      @method_name      = method_name
      @original_class   = original_class.name.to_sym
      @singleton        = singleton

      add_const_missing!

      super() if defined?(super)
    end

    def inspect
      "CopyMethod::CopiedMethod(#{original_class}#{method_symbol}#{method_name})"
    end

    private
    def quoted_method_name
      method_name.to_s.inspect
    end

    def qualified_original_class
      "::#{original_class}"
    end

    def add_const_missing!
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def const_missing(const_name)
          caller_method = caller_locations(1,1)[0].label

          super
        rescue NameError => e
          if caller_method == #{quoted_method_name} && #{qualified_original_class}.const_defined?(const_name)
            #{qualified_original_class}.const_get const_name
          else
            raise e
          end
        end
      RUBY
    end

    def method_symbol
      singleton? ? '.' : '#'
    end
  end
end
