require 'spec_helper'

describe CopyMethod do
  it 'has a version number' do
    expect(CopyMethod::VERSION).not_to be nil
  end

  context 'with a normal instance method' do
    let(:animals) do
      Class.new do
        def sleep
          :zzz
        end
      end
    end

    let (:abilities) do
      Module.new
    end

    before(:each) do
      stub_const("Animal", animals)
      stub_const("Abilities", abilities)

      animals.include abilities
    end

    context 'with CopyMethod.copy to a module' do
      let(:other_class) { Class.new }

      before(:each) do
        CopyMethod.copy :sleep, from: Animal, to: Abilities

        other_class.include Abilities
      end

      it 'copies the method' do
        expect(Abilities.instance_methods).to include :sleep
      end

      context 'when another class includes the target module' do
        before(:each) do
          other_class.include Abilities
        end

        specify 'the method works' do
          expect(other_class.new.sleep).to eq :zzz
        end
      end
    end

    context 'with CopyMethod.move to a module' do
      before(:each) do
        CopyMethod.move :sleep, from: Animal, to: Abilities
      end

      it 'moves the method' do
        expect(Abilities.instance_methods).to include :sleep
      end

      it 'removes the method from the origin' do
        expect(Animal.instance_methods(false)).to_not include :sleep
      end

      specify 'the method works as expected' do
        expect(Animal.new.sleep).to eq :zzz
      end
    end
  end

  context 'on an instance method that references a constant' do
    let(:animals) do
      Class.new do
        const_set :SOUND, "roar"

        def speak
          SOUND
        end
      end
    end

    let (:abilities) do
      Module.new
    end

    before(:each) do
      stub_const("Animal", animals)
      stub_const("Abilities", abilities)

      animals.include abilities
    end

    context 'with CopyMethod.move to a module' do
      before(:each) do
        CopyMethod.move :speak, from: Animal, to: Abilities
      end

      specify 'the method works as expected' do
        expect(Animal.new.speak).to eq Animal::SOUND
      end

      it 'still accesses the constant' do
        expect { Animal.new.speak }.to_not raise_error
      end

      it 'does not pollute the target module\'s constant lookups outside of the method call' do
        expect { Abilities::SOUND }.to raise_error NameError
      end
    end
  end
end
