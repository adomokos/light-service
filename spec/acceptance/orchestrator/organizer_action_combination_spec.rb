require 'spec_helper'
require 'test_doubles'

describe LightService::Orchestrator do
  class TestFailureError1 < StandardError
  end
  class TestFailureError2 < StandardError
  end

  class TestReduce
    extend LightService::Orchestrator

    def self.run(context, steps)
      with(context).reduce(steps)
    end

    def self.run_with_after_fail(context, steps, after_fail_method_identifiers)
      with(context).after_failing(after_fail_method_identifiers).reduce(steps)
    end

    def self.after_fail1(ctx)
      if ctx.message == 'A failure has occured.'
        raise TestFailureError1
      end
    end

    def self.after_fail2(ctx)
      raise TestFailureError2
    end
  end

  it 'responds to both actions and organizers' do
    result = TestReduce.run({ :number => 0 }, [
                              TestDoubles::AddTwoOrganizer,
                              TestDoubles::AddOneAction
                            ])

    expect(result).to be_success
    expect(result.number).to eq(3)
  end

  it 'fails fast by skipping proceeding actions/organizers after failure' do
    result = TestReduce.run({ :number => 0 }, [
                              TestDoubles::AddTwoOrganizer,
                              TestDoubles::FailureAction,
                              TestDoubles::AddOneAction
                            ])

    expect(result).not_to be_success
    expect(result.number).to eq(2)
  end

  it 'fails fast by skipping proceeding actions/organizers after failure, and runs the after_fail callback' do
    expect do
      TestReduce.run_with_after_fail({ :number => 0 }, [
                                TestDoubles::AddTwoOrganizer,
                                TestDoubles::FailureActionWithMessage
                              ], :after_fail1)
    end.to raise_error(TestFailureError1)
  end

  it 'fails fast by skipping proceeding actions/organizers after failure, and runs multiple after_fail callbacks' do
    expect do
      TestReduce.run_with_after_fail({ :number => 0 }, [
                                TestDoubles::AddTwoOrganizer,
                                TestDoubles::FailureAction
                              ], [:after_fail1, :after_fail2])
    end.to raise_error(TestFailureError2)
  end

  it 'does not run after_fail callbacks if orchestrator successful' do
    result = TestReduce.run_with_after_fail({ :number => 0 }, [
                              TestDoubles::AddTwoOrganizer,
                              TestDoubles::AddOneAction
                            ], [:after_fail1, :after_fail2])

    expect(result).to be_success
    expect(result.number).to eq(3)
  end

  it 'does not allow anything but actions and organizers' do
    expect do
      TestReduce.run({}, [double])
    end.to raise_error(RuntimeError)
  end
end
