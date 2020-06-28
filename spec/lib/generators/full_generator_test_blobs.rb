# rubocop:disable Metrics/ModuleLength, Metrics/MethodLength
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

  # There's some weird whitespace issue which prevents
  # using HEREDOCS :(
  def advanced_action_blob
    "# frozen_string_literal: true\n" \
      "\n" \
      "module My::Fancy\n" \
      "  class Action\n" \
      "    extend ::LightService::Action\n" \
      "\n" \
      "    expects  :foo, :bar\n" \
      "    promises :baz, :qux\n" \
      "\n" \
      "    executed do |ctx|\n" \
      "      foo = ctx.foo\n" \
      "      bar = ctx.bar\n" \
      "    end\n" \
      "  end\n" \
      "end"
  end

  def advanced_action_spec_blob
    <<~BLOB
      # frozen_string_literal: true
       require 'rails_helper'
       RSpec.describe My::Fancy::Action, type: :action do
        subject { described_class.execute(ctx) }
         let(:ctx) do
          {
            foo: nil,
            bar: nil,
          }
        end
         context "when executed" do
          xit "is expected to be successful" do
            expect(subject).to be_a_success
          end
           xit "is expected to promise 'baz'" do
            expect(subject.baz).to eq SomeBazClass
          end
           xit "is expected to promise 'qux'" do
            expect(subject.qux).to eq SomeQuxClass
          end
        end
      end
    BLOB
  end

  def simple_organizer_blob
    <<~BLOB
      # frozen_string_literal: true
       class MyOrganizer
        extend ::LightService::Organizer
         def self.call(params)
          with(
            #foo: params[:foo],
            #bar: params[:bar]
          ).reduce(actions)
        end
         def self.actions
          [
            #OneAction,
            #TwoAction,
          ]
        end
      end
    BLOB
  end

  def simple_organizer_spec_blob
    <<~BLOB
      # frozen_string_literal: true
       require 'rails_helper'
       RSpec.describe MyOrganizer, type: :organizer do
        subject { described_class.call(ctx) }
         let(:ctx) do
          {
            #foo: 'something foo',
            #bar: { baz: qux },
          }
        end
         context "when called" do
          xit "is expected to be successful" do
            expect(subject).to be_a_success
          end
        end
      end
    BLOB
  end

  def advanced_organizer_blob
    "# frozen_string_literal: true\n" \
      "\n" \
      "module My::Fancy\n" \
      "  class Organizer\n" \
      "    extend ::LightService::Organizer\n" \
      "\n" \
      "    def self.call(params)\n" \
      "      with(\n" \
      "        #foo: params[:foo],\n" \
      "        #bar: params[:bar]\n" \
      "      ).reduce(actions)\n" \
      "    end\n" \
      "\n" \
      "    def self.actions\n" \
      "      [\n" \
      "        #My::Fancy::OneAction,\n" \
      "        #My::Fancy::TwoAction,\n" \
      "      ]\n" \
      "    end\n" \
      "  end\n" \
      "end"
  end

  def advanced_organizer_spec_blob
    <<~BLOB
      # frozen_string_literal: true
       require 'rails_helper'
       RSpec.describe My::Fancy::Organizer, type: :organizer do
        subject { described_class.call(ctx) }
         let(:ctx) do
          {
            #foo: 'something foo',
            #bar: { baz: qux },
          }
        end
         context "when called" do
          xit "is expected to be successful" do
            expect(subject).to be_a_success
          end
        end
      end
    BLOB
  end
end
# rubocop:enable Metrics/ModuleLength, Metrics/MethodLength
