# frozen_string_literal: true

module Invariants
  ##
  # Hook method that gets called when the module is included in a class.
  # It extends the class with ClassMethods.
  #
  # @param base [Class] the class that includes the Invariants module
  def self.included(base)
    base.extend(ClassMethods)
  end

  ##
  # ClassMethods module provides class-level methods for defining invariants.
  module ClassMethods
    ##
    # Returns the hash of defined invariants for the class.
    #
    # @return [Hash] a hash of invariants where keys are invariant names and values are blocks
    def invariants
      @invariants ||= {}
    end

    ##
    # Defines an invariant with a given name and block. The block contains
    # the code to enforce the invariant.
    #
    # @param name [Symbol] the name of the invariant
    # @yield [payload] the block that enforces the invariant
    # @yieldparam payload [Object] the payload passed to the block when validating the invariant
    def invariant(name, &block)
      invariants[name] = block
    end
  end

  ##
  # Validates the specified invariants by executing their corresponding blocks
  # with the given payload.
  #
  # @param payload [Object] the payload to pass to the invariant blocks
  # @param names [Array<Symbol>] the names of the invariants to validate
  def enforce_invariants(payload, *names)
    self.class.invariants.each do |name, block|
      instance_exec(payload, &block) if names.include?(name)
    end
  end
end
