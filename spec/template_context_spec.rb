# frozen_string_literal: true

RSpec.describe LiquidDynamicContext::TemplateContext do
  describe "#resolve" do
    subject { template_context.resolve(template_string, { username: "strangertims" }) }

    let(:template_context) do
      described_class.new([resolver_a.new,
                           resolver_b.new])
    end

    let(:resolver_a) do
      Class.new(LiquidDynamicContext::BindingResolver) do
        register_binding :username,
                         :password

        protected

        def resolve(models, context)
          context.username = models[:username]
          context.password = "Super Secure Password"
        end
      end
    end

    let(:resolver_b) do
      Class.new(LiquidDynamicContext::BindingResolver) do
        register_binding :other_info

        protected

        def resolve(_models, context)
          context.other_info = {
            more_info: "Detailed INFO"
          }
        end
      end
    end

    context "with no used bindings" do
      let(:template_string) do
        <<~TEXT
          Hello World
        TEXT
      end

      it "returns an empty hash" do
        expect(subject).to be_instance_of(Hash)
        expect(subject).to be_empty
      end
    end

    context "with username variable used" do
      let(:template_string) do
        <<~TEXT
          Good morning {{ username }},

          welcome to our great product.
        TEXT
      end

      it "returns a hash with the result of binding resolver a" do
        expect(subject.keys.length).to eq(2)

        expect(subject["username"]).to eq("strangertims")
        expect(subject["password"]).to eq("Super Secure Password")
      end

      it "calls only resolver a" do
        expect_any_instance_of(resolver_a).to receive(:call).and_call_original
        expect_any_instance_of(resolver_b).to_not receive(:call).and_call_original

        subject
      end
    end

    context "with username variable used" do
      let(:template_string) do
        <<~TEXT
          Good morning {{ username }},

          welcome to our great product.
        TEXT
      end

      it "returns a hash with the result of binding resolver a" do
        expect(subject.keys.length).to eq(2)

        expect(subject["username"]).to eq("strangertims")
        expect(subject["password"]).to eq("Super Secure Password")
      end

      it "calls only resolver a" do
        expect_any_instance_of(resolver_a).to receive(:call).and_call_original
        expect_any_instance_of(resolver_b).to_not receive(:call).and_call_original

        subject
      end
    end

    context "with other info variable used" do
      let(:template_string) do
        <<~TEXT
          {{ other_info.more_info }}
        TEXT
      end

      it "returns a hash with the result of binding resolver b" do
        expect(subject.keys.length).to eq(1)

        expect(subject["other_info"]["more_info"]).to eq("Detailed INFO")
      end

      it "calls only resolver b" do
        expect_any_instance_of(resolver_b).to receive(:call).and_call_original
        expect_any_instance_of(resolver_a).to_not receive(:call).and_call_original

        subject
      end
    end

    context "with all variables used" do
      let(:template_string) do
        <<~TEXT
          {{ username }}
          {{ password }}
          {{ other_info.more_info }}
        TEXT
      end

      it "returns a hash with the result of binding resolver a and b" do
        expect(subject.keys.length).to eq(3)

        expect(subject["username"]).to eq("strangertims")
        expect(subject["password"]).to eq("Super Secure Password")
        expect(subject["other_info"]["more_info"]).to eq("Detailed INFO")
      end

      it "calls all available resolvers" do
        expect_any_instance_of(resolver_b).to receive(:call).and_call_original
        expect_any_instance_of(resolver_a).to receive(:call).and_call_original

        subject
      end
    end
  end
end
