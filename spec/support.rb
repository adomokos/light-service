RSpec.shared_context 'expect orchestrator warning' do
  around(:example) do |example|
    expect { example.run }.to warn_with StructuredWarnings::DeprecatedMethodWarning
  end
end
