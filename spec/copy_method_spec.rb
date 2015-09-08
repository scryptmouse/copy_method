require 'spec_helper'

describe CopyMethod do
  it 'has a version number' do
    expect(CopyMethod::VERSION).not_to be nil
  end

  include_context 'test classes'

  context 'when attempting to extend, include, or prepend' do
    let(:test_class) { Class.new }

    include_examples 'prepending the base module'
    include_examples 'extending the base module'
    include_examples 'including the base module'
  end

  context 'on a normal instance method' do
    context 'with CopyMethod.copy to a module' do
      include_examples 'copying methods'
    end

    context 'with CopyMethod.move to a module', move: true do
      include_examples 'moving methods'
    end
  end

  context 'on an instance method that references a constant' do
    let(:copy_method) { :speak }
    let(:copy_method_response) { const_value }

    context 'with CopyMethod.move to a module', move: true do
      include_examples 'moving methods'

      context 'and when looking up constants' do
        let(:message_label) { "something" }

        let(:location)  { double('method location', label: message_label) }
        let(:locations) { double('caller locations') }

        before(:each) do
          allow(copy_target).to receive(:const_missing).and_call_original
          allow(copy_target).to receive(:caller_locations).and_return(locations)
          expect(locations).to  receive(:[]).with(0).once.and_return(location)
        end

        context 'when calling the moved method' do
          let(:message_label) { copy_method.to_s }

          it 'finds the constant' do
            expect { call_method }.to_not raise_error

            expect(copy_target).to have_received(:caller_locations).once.with(1,1)
            expect(copy_target).to have_received(:const_missing).once.with(const_name)
          end
        end

        context 'when looking up the constant outside of the method call' do
          specify 'it raises the expected error' do
            expect { copy_target.const_get const_name }.to raise_error NameError

            expect(copy_target).to have_received(:const_missing).once.with(const_name)
          end
        end
      end
    end
  end

  context 'on a singleton method' do
    context 'copying to a module', to_module: true do
      include_context 'copying singleton methods'
    end

    context 'copying to another class', to_class: true do
      include_context 'copying singleton methods'
    end

    context 'copying to a module with explicit singleton_target', to_module: true, singleton_target: true do
      include_context 'copying singleton methods'
    end

    context 'moving to a module', to_module: true, move: true do
      include_context 'moving singleton methods'
    end

    context 'moving to another class', to_class: true, move: true do
      include_context 'moving singleton methods'
    end

    context 'moving to a module with explicit singleton_target', to_module: true, move: true, singleton_target: true do
      include_context 'moving singleton methods'
    end
  end
end
