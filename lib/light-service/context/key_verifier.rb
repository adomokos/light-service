module LightService
  class ExpectedKeysNotInContextError < StandardError; end
  class PromisedKeysNotInContextError < StandardError; end

  class Context
    class KeyVerifier
      class << self
        def verify_expected_keys_are_in_context(context, action)
          verify_keys_are_in_context(context, action.expected_keys) do |not_found_keys|
            error_message = "expected #{format_keys(not_found_keys)} to be in the context during #{action}"

            Configuration.logger.error error_message
            fail ExpectedKeysNotInContextError, error_message, caller
          end
        end

        def verify_promised_keys_are_in_context(context, action)
          return context if context.failure?

          verify_keys_are_in_context(context, action.promised_keys) do |not_found_keys|
            error_message = "promised #{format_keys(not_found_keys)} to be in the context during #{action}"

            Configuration.logger.error error_message
            fail PromisedKeysNotInContextError, error_message, caller
          end
        end

        def verify_actions_has_expects_or_promises(actions)
          actions = actions.select { |a| a.expected_keys.empty? && a.promised_keys.empty? }

          if actions.any?
            error_message = "No expected or promised keys were found in the following actions: #{format_action_names(actions)}"
            fail NoExpectsOrPromisesFoundOnActionError, error_message
          end
        end

        private

        def verify_keys_are_in_context(context, keys)
          keys ||= context.keys

          not_found_keys = keys - context.keys
          unless not_found_keys.empty?
            yield not_found_keys
          end

          context
        end

        def format_keys(keys)
          keys.map { |k| ":#{k}"}.join(', ')
        end

        def format_action_names(actions)
          actions.join(',')
        end
      end
    end
  end
end
