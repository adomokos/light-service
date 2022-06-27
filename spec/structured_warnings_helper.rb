require 'structured_warnings/test'

module StructuredWarningHelper
  module_function

  def parse_arguments(args) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    args = args.clone
    first = args.shift

    if first.is_a?(Class) && first <= StructuredWarnings::Base
      warning = first
      message = args.shift

    elsif first.is_a?(Class) && !(first <= StructuredWarnings::Base)
      raise ArgumentError, 'Warning issued with a class not inheriting from StructuredWarnings::Base'

    elsif first.is_a? StructuredWarnings::Base
      warning = first.class
      message = first.message

    elsif first.is_a? String
      warning = StructuredWarnings::StandardWarning
      message = first

    else
      warning = StructuredWarnings::Base
      message = nil
    end

    unless args.empty?
      raise ArgumentError,
            "wrong number of arguments (#{args.size + 2} for 2)"
    end

    return warning, message
  end

  def args_inspect(args)
    args.map(&:inspect).join(', ')
  end
end

RSpec::Matchers.define :warn_with do |*args|
  supports_block_expectations
  warning, message = StructuredWarningHelper.parse_arguments(args)

  match do |block|
    w = StructuredWarnings::Test::Warner.new
    StructuredWarnings.with_warner(w, &block)
    expect(w.warned?(warning, message)).to be true
  end

  failure_message do |_block|
    "<#{StructuredWarningHelper.args_inspect(args)}> has not been emitted."
  end

  failure_message_when_negated do |_block|
    "<#{StructuredWarningHelper.args_inspect(args)}> has been emitted but it was not expected."
  end
end
