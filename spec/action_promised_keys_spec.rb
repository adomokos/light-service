require 'spec_helper'
require 'test_doubles'

describe ":promises macro" do

  context "when the promised key is not in the context" do
    it "raises an ArgumentError" do
      class TestDoubles::MakesCappuccinoAction1
        include LightService::Action
        expects :coffee, :milk
        promises :cappuccino
        executed do |context|
          context[:macchiato] = "#{context.coffee} - #{context.milk}"
        end
      end

      exception_error_text = "promised :cappuccino to be in the context during TestDoubles::MakesCappuccinoAction1"
      expect {
        TestDoubles::MakesCappuccinoAction1.execute(:coffee => "espresso", :milk => "2%")
      }.to raise_error(LightService::PromisedKeysNotInContextError, exception_error_text)
    end

    it "can fail the context without fulfilling its promise" do
      class TestDoubles::MakesCappuccinoAction2
        include LightService::Action
        expects :coffee, :milk
        promises :cappuccino
        executed do |context|
          context.fail!("Sorry, something bad has happened.")
        end
      end

      result_context = TestDoubles::MakesCappuccinoAction2.execute(
                          :coffee => "espresso",
                          :milk => "2%")

      expect(result_context).to be_failure
      expect(result_context.keys).not_to include(:cappuccino)
    end
  end

  context "when the promised key is in the context" do
    it "can be set with an actual value" do
      class TestDoubles::MakesCappuccinoAction3
        include LightService::Action
        expects :coffee, :milk
        promises :cappuccino
        executed do |context|
          context.cappuccino = "#{context.coffee} - with #{context.milk} milk"
          context.cappuccino += " hot"
        end
      end

      result_context = TestDoubles::MakesCappuccinoAction3.execute(
                          :coffee => "espresso",
                          :milk => "2%")

      expect(result_context).to be_success
      expect(result_context.cappuccino).to eq("espresso - with 2% milk hot")
    end

    it "can be set with nil" do
      class TestDoubles::MakesCappuccinoAction4
        include LightService::Action
        expects :coffee, :milk
        promises :cappuccino
        executed do |context|
          context.cappuccino = nil
        end
      end
      result_context = TestDoubles::MakesCappuccinoAction4.execute(
                          :coffee => "espresso",
                          :milk => "2%")

      expect(result_context).to be_success
      expect(result_context[:cappuccino]).to be_nil
    end
  end

  it "can collect promised keys when the `promised` macro is called multiple times" do
    resulting_context = TestDoubles::MultiplePromisesAction.execute(
                            :coffee => "espresso",
                            :milk => "2%")

    expect(resulting_context.cappuccino).to eq("Cappucino needs espresso and a little milk")
    expect(resulting_context.latte).to eq("Latte needs espresso and a lot of milk")
  end

end
