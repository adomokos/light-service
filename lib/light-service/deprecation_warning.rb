module LightService
  module Deprecation
    class << self
      # Basic implementation of a deprecation warning
      def warn(message, callstack = caller)
        # Construct the warning message
        warning_message = "DEPRECATION WARNING: #{message}\n"
        warning_message += "Called from: #{callstack.first}\n" unless callstack.empty?

        # Output the warning message to stderr or a log file
        $stderr.puts warning_message

        # Additional logging or actions can be added here
      end
    end
  end
end