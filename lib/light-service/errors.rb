module LightService
  class FailWithRollbackError < StandardError; end
  class ExpectedKeysNotInContextError < StandardError; end
  class PromisedKeysNotInContextError < StandardError; end
end
