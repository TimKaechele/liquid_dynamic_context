# frozen_string_literal: true

RSpec.describe LiquidDynamicContext::BindingResolver do
  describe "#call" do
    subject do
      clazz.new.call({ my_value: "test method" })
    end

    let(:clazz) do
      Class.new(described_class) do
        register_binding :result, :result_2

        protected

        def resolve(models, context)
          context.result = models[:my_value]
          context.result_2 = models[:my_value] + " hello world"
        end
      end
    end

    it "returns a hash with the bindings" do
      expect(subject).to eq({
                              "result" => "test method",
                              "result_2" => "test method hello world"
                            })
    end
  end

  describe "#needs_to_run?" do
    subject do
      clazz.new.needs_to_run?(used_bindings)
    end

    let(:clazz) do
      Class.new(described_class) do
        register_binding :username, :testing
      end
    end
    let(:used_bindings) { [:username] }

    context "when used bindings matches available binding" do
      it { is_expected.to be true }
    end

    context "when no used bindings are availabe" do
      let(:used_bindings) { [] }

      it { is_expected.to be false }
    end

    context "when available bindings do not contain any used bindings" do
      let(:used_bindings) { [:unknown_variable] }

      it { is_expected.to be false }
    end
  end
end
