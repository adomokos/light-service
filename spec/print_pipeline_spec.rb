require 'spec_helper'
require 'test_doubles'

describe "Printing the pipeline" do
  class PrintsPipeline
    include LightService::Organizer

    def self.call(coffee, milk)
      with(:coffee => coffee, :milk => milk).print_pipeline_for(
        TestDoubles::MakesCappuccinoAction
      )
    end
  end

  it "prints the pipeline for one action" do
    coffee = double(:coffee)
    milk = double(:milk)

    printed_pipeline = PrintsPipeline.call(coffee, milk)

    printed_result = <<-eos
    ** Context snapshot :coffee, :milk
TestDoubles::MakesCappuccinoAction
  expects :coffee, :milk
  promises :cappuccino
    ** Context snapshot :coffee, :milk, :cappuccino
    eos

    expect(printed_pipeline).to eq(printed_result)
  end
end
