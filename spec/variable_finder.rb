# frozen_string_literal: true

RSpec.describe LiquidDynamicContext::VariableFinder do
  describe "#find_variables" do
    subject { described_class.new.find_variables(template_string) }

    let(:template_string) do
      <<~TEXT
        Hello World
        {% if good_user %} {{ test_variable }} {% endif %}

        {% for product in collection.products %}
          {{ product.title }}
        {% endfor %}
      TEXT
    end

    it "finds all top level variables" do
      expected_variables = %i[good_user test_variable product collection].to_set

      expect(subject.to_set).to eq(expected_variables)
    end
  end
end
