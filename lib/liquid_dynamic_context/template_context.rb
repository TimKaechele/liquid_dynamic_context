# frozen_string_literal: true

module LiquidDynamicContext
  # Main entry point to resolve variables to bindings
  class TemplateContext
    attr_reader :binding_resolvers,
                :variable_finder
    # @param binding_resolvers [Enumerable<BindingResolver>] a list of your
    #   binding resolver implementations
    # @param variable_finder [#find_variables] an instance of an object
    #   that can find variables in a liquid template
    def initialize(binding_resolvers, variable_finder: VariableFinder.new)
      @binding_resolvers = binding_resolvers
      @variable_finder = variable_finder
    end

    # Given a liquid template string and any object you may want to dynamically
    # assign as input to variables this method returns you a list of key/value
    # pairs that contain the necessary bindings for your template.
    #
    # @param template_string [String] a valid liquid template
    # @param models [Any] an object with dynamic data you want to
    #   pass to your resolvers, can be nil
    #
    # @return [Hash<String,Any>] a hash with string keys that contains the bindings
    #   for the template
    def resolve(template_string, models)
      binding_resolvers.select { |resolver| resolver.needs_to_run?(variables(template_string)) }
                       .map { |resolver| resolver.call(models) }
                       .reduce({}, &:merge!)
    end

    private

    def variables(template_string)
      variable_finder.find_variables(template_string)
    end
  end
end
