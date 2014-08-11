require 'spec_helper'

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
    class FooNoExpectedKeyAction
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
      expect { FooNoExpectedKeyAction.execute }.to \
        raise_error(LightService::ExpectedKeysNotInContextError)
    end
  end

  describe "expected keys" do
    class FooWithReaderAction
      include LightService::Action
      expects :baz

      executed do |context|
        # Notice how I use `context.baz` here
        bar = context.baz + 2
        context[:bar] = bar
      end
    end
    it "can be accessed through a reader" do
      result = FooWithReaderAction.execute(:baz => 3)
      expect(result).to be_success
      expect(result[:bar]).to eq(5)
    end
  end

  context "when promised keys are not in context" do
    class FooNoPromisedKeyAction
      include LightService::Action
      expects :baz
      promises :bar

      executed do |context|
        # I am not adding anything to the context
      end
    end
    it "throws a PromisedKeysNotInContextError" do
      # FooAction invoked with nothing placed in the context
      expect { FooNoPromisedKeyAction.execute(:baz => 3) }.to \
        raise_error(LightService::PromisedKeysNotInContextError)
    end
  end

  describe "promised keys" do
    class FooWithExpectsAndPromisesAction
      include LightService::Action
      expects :baz
      promises :bar

      executed do |context|
        # Notice how I use `context.bar` here
        context.bar = context.baz + 2
      end
    end
    it "puts the value through the accessor into the context" do
      result = FooWithExpectsAndPromisesAction.execute(:baz => 3)
      expect(result).to be_success
      expect(result[:bar]).to eq(5)
    end
  end
end
