module CopyMethod
  module Utils
    module_function

    # @param [Module, Object] object
    def looks_like_module?(object)
      object.is_a?(::Module) && ( object.class == ::Module || object.ancestors.include?(Module) )
    end

    # @param [Module, Class] thing
    # @param [Symbol] parameter_name
    # @raise [ArgumentError] if thing is not a module
    # @return [Module, Class]
    def assert_module!(thing, parameter_name = :thing)
      raise TypeError, "#{parameter_name}: #{thing.inspect} is not a `Module`" unless thing.is_a?(Module)

      return thing
    end

    def activesupport_concern?(thing)
      return false unless defined?(ActiveSupport::Concern)

      looks_like_module?(thing) && thing.kind_of?(ActiveSupport::Concern)
    end
  end
end
