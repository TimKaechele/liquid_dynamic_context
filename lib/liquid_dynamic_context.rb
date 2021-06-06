# frozen_string_literal: true

require "active_support"
# for class_attribute method
require "active_support/core_ext/class/attribute"
# for #deep_stringify_keys
require "active_support/core_ext/hash/keys"

require "liquid"

require_relative "liquid_dynamic_context/version"
require_relative "liquid_dynamic_context/binding_resolver"
require_relative "liquid_dynamic_context/template_context"
require_relative "liquid_dynamic_context/variable_finder"

module LiquidDynamicContext
  class Error < StandardError; end
end
