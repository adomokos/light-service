class ExpectedKeysNotInContextError < StandardError; end
class PromisedKeysNotInContextError < StandardError; end

class ContextKeyVerifier
  def initialize(context, expected_keys, promised_keys)
    @context = context
    @expected_keys = expected_keys
    @promised_keys = promised_keys
  end

  def verify_expected_keys_are_in_context
    verify_keys_are_in_context(@expected_keys) do |not_found_keys|
      fail ExpectedKeysNotInContextError, "expected #{format_keys(not_found_keys)} to be in the context"
    end
  end

  def verify_promised_keys_are_in_context
    verify_keys_are_in_context(@promised_keys) do |not_found_keys|
      fail PromisedKeysNotInContextError, "promised #{format_keys(not_found_keys)} to be in the context"
    end
  end

  def verify_keys_are_in_context(keys)
    keys ||= @context.keys

    not_found_keys = keys - @context.keys
    unless not_found_keys.empty?
      yield not_found_keys
    end

    @context
  end

  def format_keys(keys)
    keys.map{|k| ":#{k}"}.join(', ')
  end
end
