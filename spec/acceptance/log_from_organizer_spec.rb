require 'spec_helper'
require 'test_doubles'
require 'stringio'

describe "Logs from organizer" do
  def collects_log
    original_logger = LightService::Configuration.logger

    strio = StringIO.new
    LightService::Configuration.logger = Logger.new(strio)

    yield

    LightService::Configuration.logger = original_logger

    strio.string
  end

  context "when every action has expects or promises" do
    subject(:log_message) do
      collects_log do
        TestDoubles::MakesTeaAndCappuccino
          .call("black tea", "2% milk", "espresso coffee")
      end
    end

    it "describes what organizer was invoked" do
      organizer_log_message = "[LightService] - calling organizer " \
                              "<TestDoubles::MakesTeaAndCappuccino>"
      expect(log_message).to include(organizer_log_message)
    end

    it "describes the actions invoked" do
      organizer_log_message = "[LightService] - executing " \
                              "<TestDoubles::MakesTeaWithMilkAction>"
      expect(log_message).to include(organizer_log_message)
      organizer_log_message = "[LightService] - executing " \
                              "<TestDoubles::MakesLatteAction>"
      expect(log_message).to include(organizer_log_message)
    end

    it "lists the keys in context before the actions are executed" do
      organizer_log_message = "[LightService] -     " \
                              "keys in context: :tea, :milk, :coffee"
      expect(log_message).to include(organizer_log_message)
    end

    it "lists the expects actions are expecting" do
      organizer_log_message = "[LightService] -   expects: :tea, :milk"
      expect(log_message).to include(organizer_log_message)
      organizer_log_message = "[LightService] -   expects: :coffee, :milk"
      expect(log_message).to include(organizer_log_message)
    end

    it "lists the promises actions are promising" do
      organizer_log_message = "[LightService] -   promises: :milk_tea"
      expect(log_message).to include(organizer_log_message)
      organizer_log_message = "[LightService] -   promises: :latte"
      expect(log_message).to include(organizer_log_message)
    end

    it "lists the keys in contect after the actions are executed" do
      organizer_log_message = "[LightService] -     keys in context: " \
                              ":tea, :milk, :coffee, :milk_tea, :latte"
      expect(log_message).to include(organizer_log_message)
    end
  end

  context "when NOT every action expects or promises" do
    subject(:log_message) do
      collects_log do
        TestDoubles::MakesCappuccinoAddsTwo.call("2% milk", "espresso coffee")
      end
    end

    it "describes what organizer was invoked" do
      organizer_log_message = "[LightService] - calling organizer " \
                              "<TestDoubles::MakesCappuccinoAddsTwo>"
      expect(log_message).to include(organizer_log_message)
    end

    it "does not list empty expects or promises" do
      organizer_log_message = "[LightService] -   expects:\n"
      expect(log_message).not_to include(organizer_log_message)
      organizer_log_message = "[LightService] -   promises:\n"
      expect(log_message).not_to include(organizer_log_message)
    end
  end

  context "when the context has failed" do
    subject(:log_message) do
      collects_log do
        TestDoubles::MakesCappuccinoAddsTwoAndFails
          .call("espresso coffee")
      end
    end

    it "logs it with a warning" do
      organizer_log_message = "WARN -- : [LightService] - :-((( " \
                              "<TestDoubles::MakesLatteAction> has failed..."
      expect(log_message).to include(organizer_log_message)
      organizer_log_message = "WARN -- : [LightService] - context message: " \
                              "Can't make a latte from a milk that's very hot!"
      expect(log_message).to include(organizer_log_message)
      organizer_log_message = "[LightService] -  :-((( " \
                              "<TestDoubles::AddsTwoAction> has failed..."
      expect(log_message).not_to include(organizer_log_message)
    end
  end

  context "when the context has failed with rollback" do
    subject(:log_message) do
      collects_log do
        TestDoubles::MakesCappuccinoAddsTwoAndFails
          .call("espresso coffee", :super_hot)
      end
    end

    it "logs it with a warning" do
      organizer_log_message = "WARN -- : [LightService] - :-((( " \
                              "<TestDoubles::MakesLatteAction> has failed..."
      expect(log_message).to include(organizer_log_message)
      organizer_log_message = "WARN -- : [LightService] - context message: " \
                              "Can't make a latte from a milk that's super hot!"
      expect(log_message).to include(organizer_log_message)
      organizer_log_message = "[LightService] -  :-((( " \
                              "<TestDoubles::AddsTwoAction> " \
                              "has failed..."
      expect(log_message).not_to include(organizer_log_message)
    end
  end

  context "when the context is skipping the rest" do
    subject(:log_message) do
      collects_log do
        TestDoubles::MakesCappuccinoSkipsAddsTwo.call("espresso coffee")
      end
    end

    it "logs it with a warning" do
      organizer_log_message = "INFO -- : [LightService] - ;-) " \
                              "<TestDoubles::MakesLatteAction> has decided " \
                              "to skip the rest of the actions"
      expect(log_message).to include(organizer_log_message)
      organizer_log_message = "INFO -- : [LightService] - context message: " \
                              "Can't make a latte with a fatty milk like that!"
      expect(log_message).to include(organizer_log_message)
      organizer_log_message = "INFO -- : [LightService] - ;-) " \
                              "<TestDoubles::AddsTwoAction> has decided " \
                              "to skip the rest of the actions"
      expect(log_message).not_to include(organizer_log_message)
    end
  end
end
