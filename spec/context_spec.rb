require "spec_helper"

module LightService
  describe Context do
    subject { Context.new({:test => 1}, Outcomes::SUCCESS, "some_message") }

    it "initializes the object with default arguments" do
      service_result = Context.new({test: 1})
      service_result.should be_success
      service_result.message.should eq ""
      service_result[:test].should eq 1
    end

    it "initializes the object with the context" do
      service_result = Context.new.tap { |o| o.add_to_context({:test => 1})}
      service_result.should be_success
      service_result.message.should eq ""
      service_result[:test].should eq 1
    end

    describe ".make" do
      it "initializes the object with make" do
        service_result = Context.make({:test => 1})
        service_result.should be_success
        service_result.message.should eq ""
        service_result[:test].should eq 1
      end

      context "when passing valid parameters" do
        subject { Context.make(params).to_hash }

        let(:params) { {test: 1} }
        it { should eq({test: 1}) }

        let(:params) { Context.make(test: 1) }
        it { should eq({test: 1}) }
      end

      context "when passing invalid parameters" do
        subject { lambda {Context.make(invalid_params)} }

        let(:invalid_params) { nil }
        it { should raise_error(NoMethodError) }

        let(:invalid_params) { [] }
        it { should raise_error(NoMethodError) }
      end
    end

    describe "#to_hash" do
      it "converts context into a hash" do
        Context.make(test: 1).to_hash.should == {test: 1}
        Context.make({}).to_hash.should == {}
      end
    end

    context "when created" do
      it { should be_success }
    end

    it "allows to set success" do
      subject.set_success!("the success")
      subject.should be_success
      subject.message.should == "the success"
    end

    specify "evaluates failure?" do
      subject.set_success!("the success")
      subject.should_not be_failure
    end

    it "allows to set failure" do
      subject.set_failure!("the failure")
      subject.should_not be_success
      subject.message.should == "the failure"
    end

    it "lets setting a group of context values" do
      subject.to_hash.should include(:test => 1)
      subject.to_hash.keys.length.should == 1

      subject.add_to_context(:test => 1, :two => 2)

      subject.to_hash.keys.length.should == 2
      subject.to_hash.should include(:test => 1)
      subject.to_hash.should include(:two => 2)
    end
  end

end
