RSpec.shared_context 'expect orchestrator warning' do
  before do
    expect(ActiveSupport::Deprecation)
      .to receive(:warn)
      .with(/^`Orchestrator#/)
      .at_least(:once)
  end
end

