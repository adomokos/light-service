require 'spec_helper'

module LightService
  describe ":expects and :promises macros" do
    describe "actions are backward compatible" do
      class FooAction
        include LightService::Action

        executed do |context|
          baz = context.fetch :baz

          bar = baz + 2
          context[:bar] = bar
        end
      end
      it "works without expects and promises" do
        result = FooAction.execute(:baz => 3)
        expect(result).to be_success
        expect(result[:bar]).to eq(5)
      end
    end

    context "when expected keys are not in context" do
      class FooAction
        include LightService::Action
        expects :baz

        executed do |context|
          baz = context.fetch :baz

          bar = baz + 2
          context[:bar] = bar
        end
      end
      it "throws an ExpectedKeysNotInContextError" do
        # FooAction invoked with nothing in the context
        expect { FooAction.execute }.to raise_error(ExpectedKeysNotInContextError)
      end
    end

    describe "expected keys" do
      class FooAction
        include LightService::Action
        expects :baz

        executed do |context|
          # Notice how I use `self.baz` here
          bar = self.baz + 2
          context[:bar] = bar
        end
      end
      it "can be accessed through a reader" do
        result = FooAction.execute(:baz => 3)
        expect(result).to be_success
        expect(result[:bar]).to eq(5)
      end
    end

    describe "promised keys" do
      class FooAction
        include LightService::Action
        expects :baz
        promises :bar

        executed do |context|
          # Notice how I use `self.bar` here
          self.bar = self.baz + 2
        end
      end
      it "puts the value through the accessor into the context" do
        result = FooAction.execute(:baz => 3)
        expect(result).to be_success
        expect(result[:bar]).to eq(5)
      end
    end
  end
end
