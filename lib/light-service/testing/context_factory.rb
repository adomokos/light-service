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
          source_string =~ %r(#{action.name.demodulize})

        rebuild_actions_to(action, source_string)
      end

      private

      def source_actions
        organizer
          .method(:actions).source # get the source for the method
          .split[3...-2] # split on whitespace, remove method text
          .join(' ')     # and join into a string
      end

      def organizer_namespaces
        organizer.ancestors.first.to_s.split('::')[0...-1].map { |s| s.constantize }
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

          class OpenBoundaryLexeme < SimpleLexeme; end;
          class CloseBoundaryLexeme < SimpleLexeme; end;
          class MethodLexeme < SimpleLexeme; end;
          class ActionLexeme < SimpleLexeme; end;

          def lex(tokens)
            tokens.map do |token|
              type = if token == '['
                       OpenBoundaryLexeme
                     elsif token == ']'
                       CloseBoundaryLexeme
                     elsif organizer_method(token.to_sym)
                       MethodLexeme
                     elsif token.present?
                       ActionLexeme
                     else
                       raise ArgumentError, "Unable to parse #{token} for ContextFactory generation"
                     end

              type.new(token)
            end
          end

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
          @tokens   = tokenizer.new(/[,\s\(\)]/).tokenize(string).reject {|s| s.empty?}
          @lexemes  = lexer.new.lex(tokens)
        end

        def rebuild_to(action, namespaces)
          lexemes.map do |lexeme|
            next lexeme unless lexeme.is_a? Lexer::ActionLexeme
            token = lexeme.token
            const = if token.safe_constantize
                      token
                    else
                      namespace = namespaces.detect { |ns| ns.const_get(token) }
                      "#{namespace}::#{token}".safe_constantize
                    end
            const
          end.take_while do |current_action|
            current_action != action
          end
        end
      end
    end
  end
end
