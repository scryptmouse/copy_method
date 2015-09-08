require "method_source"
require "copy_method/version"
require "copy_method/utils"
require "copy_method/method_copier"
require "copy_method/copied_method"
require "copy_method/integration"

module CopyMethod
  module_function

  # @param [Symbol] name
  # @param [Class, Module] from
  # @param [Class, Module] to
  # @param [Boolean] singleton
  # @param [Boolean] remove
  # @param [Boolean] singleton_target
  # @return [Symbol] the method name moved
  def copy_method(name, from:, to:, **kwargs)
    kwargs[:name] = name
    kwargs[:from] = from
    kwargs[:to]   = to

    copier = CopyMethod::MethodCopier.new **kwargs

    copier.copy!
  end

  def move_method(name, **kwargs)
    kwargs[:remove] = true

    copy_method name, **kwargs
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

  class << self
    alias copy copy_method
    alias move move_method
    alias copy_singleton copy_singleton_method
    alias move_singleton move_singleton_method

    def extend_object(base)
      verb = case __method__
             when :extend_object    then 'extend'
             when :append_features  then 'include'
             when :prepend_features then 'prepend'
               # :nocov:
               'extend'
               # :nocov:
             end

      $stderr.puts "Do not #{verb} CopyMethod directly. Use CopyMethod.patch! if you want methods in classes directly."
    end

    alias prepend_features extend_object
    alias append_features extend_object

    def patch!
      Module.include CopyMethod::Integration
    end
  end
end

def CopyMethod(name, **kwargs)
  CopyMethod.copy_method name, **kwargs
end
