require 'spec_helper'

RSpec.describe LightService::Deprecation do
  context '.warn' do
    it 'outputs a message with tag, a location and a message' do
      expect { described_class.warn('A deprecation message') }
        .to output(%r{\[DEPRECATION\] .*/spec/deprecation_spec.rb:[0-9]+:in .* A deprecation message})
        .to_stderr_from_any_process
    end
  end
end
