# frozen_string_literal: true

module LiquidDynamicContext
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

    def needs_to_run?(used_bindings)
      !(bindings & used_bindings.to_set).empty?
    end

    protected

    def resolve(models, context)
      raise NotImplementedError
    end
  end
end
