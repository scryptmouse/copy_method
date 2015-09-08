module CopiedMethodHelpers
  def copied_method_should_be(method_name, klass: 'Animal', singleton: false)
    symbol = singleton ? '.' : '#'

    match_name = "CopyMethod::CopiedMethod(#{klass}#{symbol}#{method_name})"

    let(:expected_helper_name) { match_name }

    it 'names the helper module correctly' do
      expect()
    end
  end
end

RSpec.configure do |c|
  c.extend CopiedMethodHelpers
end
