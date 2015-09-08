module CopyMethod
  # @api private
  # @todo Be clever about `ActiveSupport::Concern`, if we are copying a singleton method
  #   to such a module, check for / create the `ClassMethods` submodule and place the
  #   method on that.
  class MethodCopier
    include CopyMethod::Utils

    attr_reader :method_name, :from, :to, :singleton, :remove, :singleton_target

    alias singleton_target? singleton_target
    alias remove? remove
    alias singleton? singleton
    alias singleton_origin? singleton?

    def initialize(name:, from:, to:, singleton: false, remove: false, singleton_target: nil)
      @method_name              = name
      @from                     = assert_module! from, :from
      @to                       = assert_module! to, :to
      @singleton                = singleton
      @remove                   = remove

      if singleton_target.nil?
        @singleton_target = to_module? ? false : singleton
      else
        @singleton_target = !!singleton_target
      end
    end

    def definition
      @_definition ||= fetch_method_definition
    end

    # Wrapper around {#from}
    def origin
      from
    end

    # Wrapper around {#to}.
    #
    # If copying a singleton method, the possibility that it has a
    # {#singleton_receiver} in its method body needs to be accounted for.
    #
    # @return [Class]
    def target
      if singleton_target?
        singleton_receiver? ? to : to.singleton_class
      else
        to
      end
    end

    # Where the magic happens.
    #
    # @return [Symbol]
    def copy!
      location, line = definition.source_location

      target.module_eval corrected_source, location, line

      attach_helper_module!

      remove_from_origin! if remove?

      return method_name
    end

    # @return [String]
    def method_source
      definition.source
    end

    # Populated with the `receiver` for defining singleton methods.
    #
    # In the method source, this would be something that looks like
    # `def self.foo` where `foo` is the method name, and `self` is
    # the receiver.
    #
    # Since we're copying with source, the presence of this determines
    # _where_ to define the new method on the target.
    def singleton_receiver
      @_singleton_receiver ||= singleton? ? ( method_source[receiver_rgx, 2] || '' ) : ''
    end

    def singleton_receiver?
      !singleton_receiver.empty?
    end

    def class_receiver?
      singleton_receiver? && singleton_receiver != 'self'
    end

    # @return [String]
    def corrected_source
      correct_source_receiver method_source
    end

    def from_module?
      looks_like_module? from
    end

    def to_module?
      looks_like_module? to
    end

    # This checks for the condition where we want to copy a `Class`'s
    # singleton method to a `Module`'s instance methods. By default,
    # the library assumes that you would want to copy a method for any
    # `Class` that then extends the target module.
    #
    # To override this logic, explicitly set `{#singleton_target}` to
    # `true` if providing a module to `{#to}`.
    #
    def convert_to_instance_method?
      singleton? && to_module? && !from_module? && !singleton_target?
    end

    private
    # This generates a {CopyMethod::CopiedMethod} module instance that
    # will preserve any constant accesses that were defined in the
    # {#origin}, but do not exist in the {#target}
    #
    # @return [void]
    def attach_helper_module!
      helper_mod = CopyMethod::CopiedMethod.new origin, method_name, singleton: singleton_origin?

      to.extend helper_mod
    end

    # @return [String]
    def correct_source_receiver(source)
      if convert_to_instance_method?
        source.sub receiver_rgx, '\1 \3'
      elsif singleton? && class_receiver?
        source.sub receiver_rgx, '\1self.\3'
      else
        source
      end
    end

    # @return [Regexp]
    def receiver_rgx
      /(def\s+)([^\.\s]+)\.(#{definition.name})\b/
    end

    # @return [void]
    def remove_from_origin!
      if singleton_origin?
        origin.singleton_class.__send__ :remove_method, method_name
      else
        origin.__send__ :remove_method, method_name
      end
    end

    # @return [UnboundMethod, Method]
    def fetch_method_definition
      if singleton_origin?
        origin.method method_name
      else
        origin.instance_method method_name
      end
    end
  end
end
