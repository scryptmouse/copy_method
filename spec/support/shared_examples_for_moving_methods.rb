RSpec.shared_context 'moving or copying methods to a module' do
  def target_instance_methods
    copy_target.instance_methods
  end

  def original_instance_methods
    copy_origin.instance_methods(false)
  end

  specify 'the copied method module displays the correct method name' do
    expect(copied_method_module.inspect).to include full_method_name
  end

  specify 'the method works as expected' do
    expect(call_method).to eq copy_method_response
  end

  context 'when another class includes the target module' do
    specify 'the method works' do
      expect(call_method(on: other_class.new)).to eq copy_method_response
    end
  end
end

RSpec.shared_examples 'copying methods' do
  before(:each) do
    CopyMethod.copy copy_method, **copy_options
  end

  include_context 'moving or copying methods to a module'

  it 'copies the method' do
    expect(target_instance_methods).to include copy_method
  end

  it 'keeps the method in the original class' do
    expect(original_instance_methods).to include copy_method
  end
end

RSpec.shared_examples 'moving methods' do
  before(:each) do
    CopyMethod.move copy_method, **copy_options
  end

  include_context 'moving or copying methods to a module'

  it 'moves the method' do
    expect(target_instance_methods).to include copy_method
  end

  it 'removes the method from the original class' do
    expect(original_instance_methods).to_not include copy_method
  end
end

RSpec.shared_examples 'shared singleton method tests' do
  specify do
    expect(copy_target).to be_a CopyMethod::HasCopiedMethods
  end

  if metadata[:to_module]
    if metadata[:singleton_target]
      specify 'the method is kept as a singleton method on the target' do
        expect(copy_target.methods).to include copy_method
      end

      specify { expect(copy_target).to respond_to copy_method }
    else
      specify 'the method is turned into an instance method' do
        expect(copy_target.instance_methods).to include copy_method
      end

      specify { expect(animal).to respond_to copy_method }
      specify { expect(other_class).to respond_to copy_method }
    end
  else
    specify { expect(copy_target).to respond_to copy_method }
  end
end

RSpec.shared_examples 'copied singleton method tests' do
  specify 'the origin still responds to method' do
    expect(copy_origin).to respond_to copy_method
  end
end

RSpec.shared_examples 'moved singleton method tests' do
  specify 'the origin no longer responds to method' do
    expect(copy_origin).to_not respond_to copy_method
  end if metadata[:to_class] || metadata[:singleton_target]
end

RSpec.shared_context 'moving or copying singleton methods' do
  let(:self_receiver_method) { :foo }
  let(:eigen_method) { :bar }
  let(:named_receiver_method) { :baz }
  let(:from_singleton) { true }

  let(:copy_target) do |example|
    if example.metadata[:to_class]
      other_class
    elsif example.metadata[:to_module]
      scopes
    else
      raise "set to_class or to_module metadata"
    end
  end

  before(:each) do
    if move_method
      CopyMethod.move_singleton copy_method, **copy_options
    else
      CopyMethod.copy_singleton copy_method, **copy_options
    end
  end

  context 'with a method defined on the eigenclass' do
    let(:copy_method) { eigen_method }

    include_examples 'shared singleton method tests'

    if metadata[:move]
      include_examples 'moved singleton method tests'
    else
      include_examples 'copied singleton method tests'
    end
  end

  context 'with a method defined with a class name as the receiver' do
    let(:copy_method) { named_receiver_method }

    include_examples 'shared singleton method tests'

    if metadata[:move]
      include_examples 'moved singleton method tests'
    else
      include_examples 'copied singleton method tests'
    end
  end

  context 'with a method defined with self as the receiver' do
    let(:copy_method) { self_receiver_method }

    include_examples 'shared singleton method tests'

    if metadata[:move]
      include_examples 'moved singleton method tests'
    else
      include_examples 'copied singleton method tests'
    end
  end
end

RSpec.shared_context 'copying singleton methods' do
  include_context 'moving or copying singleton methods'
end

RSpec.shared_context 'moving singleton methods' do
  include_context 'moving or copying singleton methods'
end
