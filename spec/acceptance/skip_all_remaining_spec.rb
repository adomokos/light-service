require 'spec_helper'

RSpec.describe "skip_all_remaining!" do
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
            execute(lambda(&:skip_all_remaining!)),
            execute(->(c) { c[:second] = true })
          ]
        end
      end
    end

    it "skips all remaining actions" do
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

        def self.actions
          [
            reduce_if(
              ->(_) { true },
              [
                execute(->(c) { c[:first_inside] = true }),
                execute(lambda(&:skip_all_remaining!)),
                execute(->(c) { c[:second_inside] = true })
              ]
            ),
            execute(->(c) { c[:outside] = true })
          ]
        end
      end
    end

    it "skips all remaining actions inside and outside the reducer" do
      result = organizer.call(LightService::Context.make)

      expect(result[:first_inside]).to be true
      expect(result[:second_inside]).to be_nil
      expect(result[:outside]).to be_nil
    end
  end

  context "with an organizer with nested reducers" do
    let(:organizer) do
      Class.new do
        extend LightService::Organizer

        def self.call(ctx)
          with(ctx).reduce(actions)
        end

        def self.actions # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
          [
            reduce_if(
              ->(_) { true },
              [
                iterate(:items, [
                          execute(lambda { |c|
                            c[:executed_items] ||= []
                            c[:executed_items] << c[:item]
                          }),
                          execute(->(c) { c.skip_all_remaining! if c[:item] == 2 }),
                          execute(lambda { |c|
                            c[:skipped_in_iterate] ||= []
                            c[:skipped_in_iterate] << c[:item]
                          })
                        ]),
                execute(->(c) { c[:after_iterate_inside_if] = true })
              ]
            ),
            execute(->(c) { c[:outside] = true })
          ]
        end
      end
    end

    it "skips all remaining actions across all nested scopes" do
      result = organizer.call(LightService::Context.make(:items => [1, 2, 3]))

      expect(result[:executed_items]).to eq([1, 2])
      expect(result[:skipped_in_iterate]).to eq([1])
      expect(result[:after_iterate_inside_if]).to be_nil
      expect(result[:outside]).to be_nil
    end
  end
end
