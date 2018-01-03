module LightService
  module Organizer
    class Execute
      def self.run(code_block)
        lambda do |ctx|
          return ctx if ctx.stop_processing?

          code_block.call(ctx)
          ctx
        end
      end
    end
  end
end
