RSpec.shared_context 'expect orchestrator warning' do
  before do
    expect(LightService)
      .to receive(:deprecation_warning)
      .with(/^`Orchestrator#/)
      .at_least(:once)
  end
end

