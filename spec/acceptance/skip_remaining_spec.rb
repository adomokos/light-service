require 'spec_helper'

RSpec.describe "skip_remaining!" do
  context "with regular organizer" do
    let(:organizer) do
      Class.new do
        extend LightService::Organizer

        def self.call(ctx)
          with(ctx).reduce(actions)
        end

        def self.actions
          [
            execute(->(c) { c[:first] = true }),
            execute(lambda(&:skip_remaining!)),
            execute(->(c) { c[:second] = true })
          ]
        end
      end
    end

    it "skips the remaining actions in the organizer" do
      result = organizer.call(LightService::Context.make)

      expect(result[:first]).to be true
      expect(result[:second]).to be_nil
    end
  end

  context "with an organizer with a reducer" do
    let(:organizer) do
      Class.new do
        extend LightService::Organizer

        def self.call(ctx)
          with(ctx).reduce(actions)
        end

        def self.actions # rubocop:disable Metrics/AbcSize
          [
            iterate(:items, [
                      execute(lambda { |c|
                        c[:executed_items] ||= []
                        c[:executed_items] << c[:item]
                      }),
                      execute(->(c) { c.skip_remaining! if c[:item] == 2 }),
                      execute(lambda { |c|
                        c[:skipped_actions] ||= []
                        c[:skipped_actions] << c[:item]
                      })
                    ]),
            execute(->(c) { c[:outside_iterate] = true })
          ]
        end
      end
    end

    it "only skips remaining actions for the current item in the reducer" do
      result = organizer.call(LightService::Context.make(:items => [1, 2, 3]))

      expect(result[:executed_items]).to eq([1, 2, 3])
      expect(result[:skipped_actions]).to eq([1, 3])
      expect(result[:outside_iterate]).to be true
    end
  end
end

