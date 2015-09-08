require 'pry'

RSpec.shared_context 'test classes' do
  let :animal do
    Class.new do
      def sleep
        :zzz
      end

      def speak
        SOUND
      end

      def self.foo
      end

      class << self
        def bar
        end
      end
    end
  end

  let(:other_class) { Class.new }

  let(:abilities) { Module.new }

  let(:scopes) { Module.new }

  let(:copy_origin)   { animal }
  let(:copy_target)   { abilities }
  let(:copy_method)   { :sleep }
  let(:copy_method_response) { :zzz }
  let(:const_name)    { :SOUND }
  let(:const_value)   { :roar }
  let(:instance)      { copy_origin.new }

  let :from_singleton do |example|
    example.metadata.fetch :singleton, false
  end

  let :move_method do |example|
    example.metadata.fetch :move, false
  end

  let :singleton_target do |example|
    example.metadata.fetch :singleton_target, false
  end

  let :full_method_name do
    symbol = from_singleton ? '.' : '#'

    "#{copy_origin.name}#{symbol}#{copy_method}"
  end

  let :copied_method_module do
    copy_target.copied_method_modules.detect do |mod|
      mod.method_name == copy_method && mod.original_class == copy_origin.name.to_sym
    end
  end

  let :copy_options do
    {
      from: copy_origin,
      to:   copy_target
    }.tap do |hsh|
      hsh[:singleton] = true if from_singleton
      hsh[:remove]    = true if move_method
      hsh[:singleton_target] = true if singleton_target
    end
  end

  before(:each) do
    stub_const 'Animal', animal
    stub_const 'Animal::SOUND', const_value
    stub_const 'OtherClass', other_class
    stub_const 'Abilities', abilities
    stub_const 'Scopes', scopes

    Animal.include Abilities
    OtherClass.include Abilities
    Animal.extend Scopes
    OtherClass.extend Scopes

    def Animal.baz
    end
  end
end
