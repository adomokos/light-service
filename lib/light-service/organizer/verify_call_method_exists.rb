module LightService
  module Organizer
    # We need to make sure existing users will
    # use `call` method name going forward.
    # This should be removed eventually.
    class VerifyCallMethodExists
      def self.run(klass, first_caller = '')
        invoker_method = caller_method(first_caller)
        return if invoker_method == 'call'

        call_method_exists = klass.methods.include?(:call)
        return if call_method_exists

        warning_msg = "The <#{klass.name}> class is an organizer, " \
                      "its entry method (the one that calls with & reduce) " \
                      "should be named `call`. " \
                      "Please use #{klass}.call going forward."
        warn(StructuredWarnings::DeprecatedMethodWarning, warning_msg)
      end

      def self.caller_method(first_caller)
        return nil unless first_caller =~ /`(.*)'/

        Regexp.last_match[1]
      end
    end
  end
end
