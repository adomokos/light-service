require "spec_helper"

module LightService
  describe Context do
    subject { Context.new({:test => 1}, Outcomes::SUCCESS, "some_message") }

    it "initializes the object with default arguments" do
      service_result = Context.new({test: 1})

      expect(service_result).to be_success
      expect(service_result.message).to eq ''
      expect(service_result[:test]).to eq 1
    end

    it "initializes the object with the context" do
      service_result = Context.new.tap { |o| o.add_to_context({test: 1})}

      expect(service_result).to be_success
      expect(service_result.message).to eq ''
      expect(service_result[:test]).to eq 1
    end

    describe ".make" do
      it "initializes the object with make" do
        service_result = Context.make({test: 1})

        expect(service_result).to be_success
        expect(service_result.message).to eq ""
        expect(service_result[:test]).to eq 1
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

      context "data is a context" do
        let(:original_context) { Context.new }

        it "returns the same context object" do
          new_context = Context.make(original_context)
          expect(new_context.object_id).to eq(original_context.object_id)
        end
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
      subject.set_success!('the success')

      expect(subject).to be_success
      expect(subject).not_to be_failure
      expect(subject.message) == 'the success'
    end

    it "allows to set failure" do
      subject.set_failure!('the failure')

      expect(subject).not_to be_success
      expect(subject).to be_failure
      expect(subject.message).to eq('the failure')
    end

    it "allows to set skip_all" do
      subject.skip_all!('the reason to skip')

      expect(subject).to be_skip_all
      expect(subject).to be_success
      expect(subject).not_to be_failure
      expect(subject.message).to eq('the reason to skip')
    end

    it "lets setting a group of context values" do
      subject.to_hash.should include(test: 1)
      subject.to_hash.keys.length.should == 1

      subject.add_to_context(test: 1, two: 2)

      expect(subject.to_hash.keys.length).to eq(2)
      expect(subject.to_hash).to include(test: 1)
      expect(subject.to_hash).to include(two: 2)
    end
  end

end
