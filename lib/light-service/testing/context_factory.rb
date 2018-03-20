module LightService
  module Testing
    class ContextFactory
      class ContextFactoryOrganizer
        extend LightService::Organizer
        class << self
          attr_accessor :actions
        end

        def self.call(ctx)
          with(ctx).reduce(actions)
        end
      end

      attr_reader :organizer

      def self.make_from(organizer)
        new(organizer)
      end

      def for(action)
        ContextFactoryOrganizer.actions = find_up_to(action)
        self
      end

      def with(ctx)
        ContextFactoryOrganizer.call(ctx)
      end

      def initialize(organizer)
        @organizer = organizer
      end

      def find_up_to(action)
        source_string = source_actions

        raise ArgumentError, "#{action} is not in #{organizer.name}" unless
          source_string =~ /#{action.name.demodulize}/

        rebuild_actions_to(action, source_string)
      end

      private

      def source_actions
        organizer
          .method(:actions).source # get the source for the method
          .split[3...-2] # split on whitespace, remove method text and brackets
          .join(' ')     # and join into a string
      end

      def organizer_namespaces
        organizer.ancestors.first # get class ancestors for namespaces
                 .to_s.split('::')[0...-1] # split module names, ignore class
                 .map(&:constantize) # constantize for use with action strings
      end

      def rebuild_actions_to(action, source)
        ActionParser.new(source).rebuild_to(action, organizer_namespaces)
      end

      class ActionParser
        class Tokenizer
          attr_reader :delimiter

          def initialize(delimiter)
            @delimiter = delimiter
          end

          def tokenize(string)
            string.split(delimiter)
          end
        end

        class Lexer
          class SimpleLexeme
            attr_reader :token

            def initialize(token)
              @token = token
            end

            delegate :to_s, :to => :token
          end

          class OpenBoundaryLexeme < SimpleLexeme; end
          class CloseBoundaryLexeme < SimpleLexeme; end
          class MethodLexeme < SimpleLexeme; end
          class SymbolLexeme < SimpleLexeme
            def initialize(token)
              @token = token.tr(':', '')
            end
          end
          class ActionLexeme < SimpleLexeme; end

          # rubocop:disable Metrics/MethodLength
          def lex(tokens)
            tokens.map do |token|
              type = if token == '['
                       OpenBoundaryLexeme
                     elsif token == ']'
                       CloseBoundaryLexeme
                     elsif organizer_method(token.to_sym)
                       MethodLexeme
                     elsif token.starts_with? ':'
                       SymbolLexeme
                     elsif token.present?
                       ActionLexeme
                     else
                       raise ArgumentError, "ContextFactory generation:" \
                         " unable to parse #{token}"
                     end

              type.new(token)
            end
          end
          # rubocop:enable Metrics/MethodLength

          private

          def organizer_method(token)
            LightService::Organizer::ClassMethods
              .instance_methods
              .include? token
          end
        end

        attr_reader :original, :tokens, :lexemes

        def initialize(string, tokenizer: Tokenizer, lexer: Lexer)
          @original = string
          @tokens   = tokenizer.new(/[,\s\(\)]/)
                               .tokenize(string)
                               .reject(&:empty?)
          @lexemes  = lexer.new.lex(tokens)
        end

        def rebuild_to(action, namespaces)
          found_action = false

          action_set = lexemes.map do |lexeme|
            next lexeme unless lexeme.is_a? Lexer::ActionLexeme
            next if found_action

            const = namespace_token(lexeme.token, namespaces)
            next if (found_action = action == const)
            const
          end.compact

          compounded_actions = compound_boundaries(action_set)
          rebuilt_set = expand_methods(compounded_actions)

          rebuilt_set
        end

        def namespace_token(token, namespaces)
          if token.safe_constantize
            token
          else
            namespace = namespaces.detect { |ns| ns.const_get(token) }
            "#{namespace}::#{token}".safe_constantize
          end
        end

        def compound_boundaries(actions)
          open_bound = actions.find_index do |lexeme|
            lexeme.is_a? Lexer::OpenBoundaryLexeme
          end
          close_bound = actions.rindex do |lexeme|
            lexeme.is_a? Lexer::CloseBoundaryLexeme
          end

          return actions unless open_bound && close_bound

          reduced_set = actions.slice!(Range.new(open_bound, close_bound))
          new_set = compound_boundaries(reduced_set[1...-1])
          actions.insert(open_bound, new_set)

          actions
        end

        def expand_methods(actions)
          method_index = actions.rindex { |ele| ele.is_a? Lexer::MethodLexeme }
          return actions unless method_index

          pulled_expression = actions.slice!(method_index,
                                             method_argument_count + 1)

          expanded_method =
            expand_method(
              pulled_expression
            )

          actions.insert(method_index, expanded_method) if expanded_method
          expand_methods(actions)

          actions
        end

        private

        def method_argument_count
          2 # every method takes an action, block, or symbol and a set of steps
        end

        def expand_method(pulled_expression)
          method_lexeme, argument, steps = pulled_expression
          return nil unless argument.present?

          method = method_lexeme.token.to_sym
          argument = if argument.is_a? Lexer::SymbolLexeme
                       argument.token.to_sym
                     else
                       argument
                     end

          if (method == :reduce_until || method == :iterate) && steps.any?
            raise "Cannot partially #{method} in" \
            " an Organizer with a ContextFactory"
          end

          LightService::Testing::ContextFactory::ContextFactoryOrganizer
            .send(method, argument, steps)
        end
      end
    end
  end
end
