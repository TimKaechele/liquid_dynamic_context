# frozen_string_literal: true

module LiquidDynamicContext
  # Abstract base class with convenience methods to
  # implement a resolver for bindings
  #
  # @example How to implement your own resolver
  #   class MyResolver < LiquidDynamicContext
  #     register_binding :username
  #
  #     protected
  #
  #     # Method that needs to be implemented by custom implementation
  #     def resolve(models, context)
  #       context.username = User.find(models[:user_id]).username
  #     end
  #   end
  class BindingResolver
    class_attribute :bindings
    self.bindings = Set.new

    def self.register_binding(*bindings)
      self.bindings = self.bindings + bindings.to_set
    end

    def call(models)
      context = Struct.new(*self.class.bindings).new
      resolve(models, context)
      context.to_h.deep_stringify_keys
    end

    # Given a list of bindings in the template this method determines
    # whether the resolver needs to run
    #
    # @param used_bindings [Enumerable<Symbol>] a list of bindings that were used in
    #   the template
    #
    # @return [Boolean] true or false depending on whether this resolver provides
    #   any of the used bindings
    def needs_to_run?(used_bindings)
      !(bindings & used_bindings.to_set).empty?
    end

    protected
    # Method to implemented by subclasses
    #
    # @param models [Any] An object that can be used to provide dynamic content
    # @param context [Struct] A struct to assign the output of your resolver to
    def resolve(models, context)
      raise NotImplementedError
    end
  end
end
