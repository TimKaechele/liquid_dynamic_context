# frozen_string_literal: true

module LiquidDynamicContext
  class VariableFinder

    # Extracts all used variables from a liquid template.
    #
    # @param template_string [String] a string with a valid liquid template
    #
    # @return an enumerable with the variables found in the template, the variables
    #   are represented as symbols
    def find_variables(template_string)
      parsed_template = Liquid::Template.parse(template_string)

      variable_lookups(parsed_template)
        .flatten
        .compact
        .map { |variable| variable.split(".").first }
        .map(&:to_sym)
        .uniq
    end

    private

    def variable_lookups(parsed_template)
      Liquid::ParseTreeVisitor.for(parsed_template.root)
                              .add_callback_for(Liquid::VariableLookup) do |node|
        [node.name, *node.lookups].join(".")
      end
                              .visit
    end
  end
end
