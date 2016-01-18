require 'spec_helper'
require 'test_doubles'

describe "Executing arbitrary code around each action" do
  def assert_before_action_execute_log
    expect(MyLogger).to receive(:info)
      .with(TestDoubles::AddsTwoActionWithFetch, :number => 0)
  end

  def assert_after_action_execute_log
    expect(MyLogger).to receive(:info)
      .with(TestDoubles::AddsTwoActionWithFetch, :number => 2)
  end

  it "can be used to log data" do
    MyLogger = double
    context = { :number => 0 }

    assert_before_action_execute_log
    assert_after_action_execute_log

    result = TestDoubles::AroundEachOrganizer.add(context)

    expect(result.fetch(:number)).to eq(2)
  end
end

