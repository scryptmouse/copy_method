module CopyMethodHelpers
  def call_method(on: instance)
    on.__send__ copy_method
  end
end

RSpec.configure do |c|
  c.include CopyMethodHelpers
end
