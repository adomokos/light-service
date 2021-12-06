module LightService
  class FailWithRollbackError < StandardError; end

  class ExpectedKeysNotInContextError < StandardError; end

  class PromisedKeysNotInContextError < StandardError; end

  class ReservedKeysInContextError < StandardError; end

  class UnusableExpectKeyDefaultError < StandardError; end

  class InvalidKeysError < StandardError; end

  class InvalidExpectOptionError < StandardError; end
end
