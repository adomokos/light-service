require 'spec_helper'
require 'test_doubles'
require 'stringio'

describe "Logs from organizer" do
  class MakesTeaAndCappuccino
    include LightService::Organizer

    def self.call(tea, milk, coffee)
      with(:tea => tea, :milk => milk, :coffee => coffee)
          .reduce(TestDoubles::MakesTeaWithMilkAction,
                  TestDoubles::MakesLatteAction)
    end
  end

  subject(:log_message) do
    original_logger = LightService::Configuration.logger

    strio = StringIO.new
    LightService::Configuration.logger = Logger.new(strio)

    result = MakesTeaAndCappuccino.call("black tea", "2% milk", "espresso coffee")
    expect(result).to be_success

    LightService::Configuration.logger = original_logger

    strio.string
  end

  it "describes what organizer was invoked" do
    organizer_log_message = "[LightService] - calling organizer MakesTeaAndCappuccino"
    expect(log_message).to include(organizer_log_message)
  end

  it "describes the actions invoked" do
    organizer_log_message = "[LightService] - executing TestDoubles::MakesTeaWithMilkAction"
    expect(log_message).to include(organizer_log_message)
    organizer_log_message = "[LightService] - executing TestDoubles::MakesLatteAction"
    expect(log_message).to include(organizer_log_message)
  end

end
