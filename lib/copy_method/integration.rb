module CopyMethod
  module Integration
    def copy_method(name, from: nil, to: nil, remove: false, singleton: false)
      if from.nil? && to.nil?
        raise ArgumentError, "must specify either `from` or `to` keywords"
      end

      from  = self if from.nil?
      to    = self if to.nil?

      CopyMethod.copy_method name, from: from, to: to, remove: remove, singleton: singleton
    end

    def move_method(name, **kwargs)
      kwargs[:remove] = true

      copy_method name **kwargs
    end

    def copy_singleton_method(name, **kwargs)
      kwargs[:singleton] = true

      copy_method name, **kwargs
    end

    def move_singleton_method(name, **kwargs)
      kwargs[:singleton]  = true
      kwargs[:remove]     = true

      copy_method name, **kwargs
    end
  end
end
