describe CopyMethod::Utils do
  describe 'looks_like_module?' do
    def call_method(target)
      described_class.looks_like_module?(target)
    end

    subject { call_method(target) }

    let (:module_instance)  { Module.new }
    let (:module_subclass)  { Class.new(Module) }
    let (:klass)            { Class.new }
    let (:object)           { Object.new }

    context 'with a module' do
      let(:target) { module_instance }

      it { is_expected.to be true }
    end

    context 'with a module subclass' do
      let(:target) { module_subclass }

      it { is_expected.to be true }
    end

    context 'with a class' do
      let(:target) { klass }

      it { is_expected.to be false }
    end

    context 'with an object' do
      let(:target) { object }

      it { is_expected.to be false }
    end
  end

  describe 'activesupport_concern?' do
    subject { described_class.activesupport_concern?(target) }

    let(:target) { Module.new }

    context 'when ActiveSupport::Concern is undefined' do
      it { is_expected.to be false }
    end

    context 'when ActiveSupport::Concern is defined' do
      let(:fake_concern) { Module.new }

      before(:each) do
        stub_const 'ActiveSupport::Concern', fake_concern
      end

      context 'on a non-concern' do
        it { is_expected.to be false }
      end

      context 'on a concern' do
        before(:each) do
          target.extend fake_concern
        end

        it { is_expected.to be true }
      end
    end
  end
end
