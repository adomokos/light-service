require 'spec_helper'

RSpec.describe LightService::Deprecation do
  describe '.warn' do
    it 'outputs a deprecation warning to stderr' do
      expect { described_class.warn('foo is deprecated') }
        .to output(/DEPRECATION WARNING: foo is deprecated/).to_stderr
    end

    it 'includes the caller location' do
      expect { described_class.warn('bar is deprecated') }
        .to output(/Called from:/).to_stderr
    end

    it 'calls Kernel.warn instead of recursing into itself' do
      expect(Kernel).to receive(:warn).with(/DEPRECATION WARNING: test message/)
      described_class.warn('test message')
    end
  end
end
