require 'spec_helper'
require 'test_doubles'

RSpec.describe LightService::Context do
  subject(:context) { LightService::Context.make }

  describe 'to_s' do
    it 'prints the context hash' do
      expect(context.to_s).to eq('{}')
    end
  end

  describe '#inspect' do
    it 'inspects the hash with all the fields' do
      inspected_context =
        "LightService::Context({}, success: true, message: '', error_code: nil, skip_remaining: false, " \
        "skip_all_remaining: false, aliases: {})"

      expect(context.inspect).to eq(inspected_context)
    end

    it 'prints the error message' do
      context.fail!('There was an error')

      inspected_context =
        "LightService::Context({}, success: false, message: 'There was an error', error_code: nil, " \
        "skip_remaining: false, skip_all_remaining: false, aliases: {})"

      expect(context.inspect).to eq(inspected_context)
    end

    it 'prints skip_remaining' do
      context.skip_remaining!('No need to process')

      inspected_context =
        "LightService::Context({}, success: true, message: 'No need to process', error_code: nil, " \
        "skip_remaining: true, skip_all_remaining: false, aliases: {})"

      expect(context.inspect).to eq(inspected_context)
    end
  end
end
