RSpec::Matchers.define :inherit do |expected|
  match do |actual|
    actual = silence(&actual) if actual.is_a?(Proc)

    actual < expected
  end

  description do
    "inherits #{expected}"
  end

  failure_message do |actual|
    "expected that #{actual} would inherit #{expected}"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not inherit #{expected}"
  end

  supports_block_expectations

  def silence(&block)
    original_stderr = $stderr
    original_stdout = $stdout

    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")

    yield
  ensure
    $stderr.close rescue nil
    $stdout.close rescue nil
    $stderr = original_stderr
    $stdout = original_stdout
  end
end

RSpec::Matchers.define_negated_matcher :not_inherit, :inherit do |desc|
  "#{desc.sub('inherits', 'not inherit')}"
end
