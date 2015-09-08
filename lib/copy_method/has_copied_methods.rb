module CopyMethod
  # Extended on classes that have received copied methods.
  module HasCopiedMethods
    # Get a list of all {CopyMethod::CopiedMethod}s this class has.
    #
    # @return [<CopyMethod::CopiedMethod>]
    def copied_method_modules
      singleton_class.ancestors.select do |anc|
        anc.is_a?(CopyMethod::CopiedMethod)
      end
    end
  end
end
