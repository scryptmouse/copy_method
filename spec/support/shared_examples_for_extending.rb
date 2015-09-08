GERUNDS = { :include => :including, :extend => :extending, :prepend => :prepending }

GERUNDS.each do |(verb, gerund)|
  RSpec.shared_examples "#{gerund} the base module" do
    context "when #{gerund}" do
      let(:verb) { verb }

      def try_to_verb_module!
        test_class.__send__ verb, CopyMethod
      end

      specify { expect { try_to_verb_module! }.to output(/use CopyMethod\.patch!/i).to_stderr }

      specify { expect { try_to_verb_module! }.to not_inherit(CopyMethod) }
    end
  end
end
