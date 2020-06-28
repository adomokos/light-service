module FullGeneratorTestBlobs
  def simple_action_blob
    <<~BLOB
      # frozen_string_literal: true

      class MyAction
        extend ::LightService::Action


        executed do |ctx|
        end

        rolled_back do |ctx|
        end
      end
    BLOB
  end

  def simple_action_spec_blob
    <<~BLOB
      # frozen_string_literal: true

      require 'rails_helper'

      RSpec.describe MyAction, type: :action do
        subject { described_class.execute(ctx) }

        let(:ctx) do
          {
          }
        end

        context "when executed" do
          xit "is expected to be successful" do
            expect(subject).to be_a_success
          end
        end
      end
    BLOB
  end
end
