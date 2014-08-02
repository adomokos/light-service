module Organizer
  class PipelinePrinter

    def initialize(context)
      @context = context
    end

    def print(*actions)
      print_result = print_context

      actions.reduce(print_result) do |print_result, action|
        print_result << "#{action.to_s}\n"
        print_result << "  expects "
        print_result << action.expects.map {|key| ":#{key}"}.join(', ')
        print_result << "\n  promises "
        print_result << action.promises.map {|key| ":#{key}"}.join(', ')
        print_result << "\n"
        action.promises.each do |promise|
          @context[promise] = nil
        end
        print_result << print_context
      end
    end

    private

    def print_context
      print_result = "    ** Context snapshot "
      print_result += @context.keys.map {|key| ":#{key}" }.join(', ')
      print_result += "\n"
    end

  end
end
