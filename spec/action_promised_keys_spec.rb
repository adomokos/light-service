require 'spec_helper'
require 'test_doubles'

describe ":promises macro" do
  context "when the promised key is not in the context" do
    it "raises an ArgumentError" do
      module TestDoubles
        class MakesCappuccinoAction1
          extend LightService::Action
          expects :coffee, :milk
          promises :cappuccino
          executed do |context|
            context[:macchiato] = "#{context.coffee} - #{context.milk}"
          end
        end
      end

      exception_msg = "promised :cappuccino to be in the context during " \
                      "TestDoubles::MakesCappuccinoAction1"
      expect do
        TestDoubles::MakesCappuccinoAction1.execute(:coffee => "espresso",
                                                    :milk => "2%")
      end.to \
        raise_error(LightService::PromisedKeysNotInContextError, exception_msg)
    end

    it "can fail the context without fulfilling its promise" do
      module TestDoubles
        class MakesCappuccinoAction2
          extend LightService::Action
          expects :coffee, :milk
          promises :cappuccino
          executed do |context|
            context.fail!("Sorry, something bad has happened.")
          end
        end
      end

      result_context = TestDoubles::MakesCappuccinoAction2
                       .execute(:coffee => "espresso",
                                :milk => "2%")

      expect(result_context).to be_failure
      expect(result_context.keys).not_to include(:cappuccino)
    end
  end

  context "when the promised key is in the context" do
    it "can be set with an actual value" do
      module TestDoubles
        class MakesCappuccinoAction3
          extend LightService::Action
          expects :coffee, :milk
          promises :cappuccino
          executed do |context|
            context.cappuccino = "#{context.coffee} - with #{context.milk} milk"
            context.cappuccino += " hot"
          end
        end
      end

      result_context = TestDoubles::MakesCappuccinoAction3
                       .execute(:coffee => "espresso",
                                :milk => "2%")

      expect(result_context).to be_success
      expect(result_context.cappuccino).to eq("espresso - with 2% milk hot")
    end

    it "can be set with nil" do
      module TestDoubles
        class MakesCappuccinoAction4
          extend LightService::Action
          expects :coffee, :milk
          promises :cappuccino
          executed do |context|
            context.cappuccino = nil
          end
        end
      end
      result_context = TestDoubles::MakesCappuccinoAction4
                       .execute(:coffee => "espresso",
                                :milk => "2%")

      expect(result_context).to be_success
      expect(result_context[:cappuccino]).to be_nil
    end
  end

  context "when a reserved key is listed as a promised key" do
    it "raises error indicating a reserved key has been promised" do
      exception_msg = "promised or expected keys cannot be a reserved key: "\
                      "[:message]"
      expect do
        TestDoubles::MakesTeaPromisingReservedKey.execute(:tea => "black")
      end.to \
        raise_error(LightService::ReservedKeysInContextError, exception_msg)
    end

    it "raises error indicating multiple reserved keys have been promised" do
      exception_msg = "promised or expected keys cannot be a reserved key: " \
                      "[:message, :error_code, :current_action]"
      expect do
        ctx = { :tea => "black" }
        TestDoubles::MakesTeaPromisingMultipleReservedKeys.execute(ctx)
      end.to \
        raise_error(LightService::ReservedKeysInContextError, exception_msg)
    end
  end

  context "when the `promised` macro is called multiple times" do
    it "collects promised keys " do
      result = TestDoubles::MultiplePromisesAction \
               .execute(:coffee => "espresso", :milk => "2%")

      expect(result.cappuccino).to \
        eq("Cappucino needs espresso and a little milk")
      expect(result.latte).to \
        eq("Latte needs espresso and a lot of milk")
    end
  end
end
