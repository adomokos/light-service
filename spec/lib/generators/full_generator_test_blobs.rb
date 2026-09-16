# rubocop:disable Metrics/ClassLength
class FullGeneratorTestBlobs
  def self.simple_action_blob
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

  def self.simple_action_spec_blob
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

  def self.advanced_action_blob
    <<~BLOB.chomp
      # frozen_string_literal: true

      module My::Fancy
        class Action
          extend ::LightService::Action

          expects  :foo, :bar
          promises :baz, :qux

          executed do |ctx|
            foo = ctx.foo
            bar = ctx.bar
          end
        end
      end
    BLOB
  end

  def self.advanced_action_spec_blob
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

  def self.pluralized_action_blob
    <<~BLOB
      # frozen_string_literal: true

      class FetchUsers
        extend ::LightService::Action

        executed do |ctx|
        end

        rolled_back do |ctx|
        end
      end
    BLOB
  end

  def self.pluralized_action_spec_blob
    <<~BLOB
      # frozen_string_literal: true

      require 'rails_helper'

      RSpec.describe FetchUsers, type: :action do
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

  def self.namespaced_pluralized_action_blob
    <<~BLOB.chomp
      # frozen_string_literal: true

      module Users
        class FetchUsers
          extend ::LightService::Action

          executed do |ctx|
          end

          rolled_back do |ctx|
          end
        end
      end
    BLOB
  end

  def self.namespaced_pluralized_action_spec_blob
    <<~BLOB
      # frozen_string_literal: true

      require 'rails_helper'

      RSpec.describe Users::FetchUsers, type: :action do
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

  def self.pluralized_organizer_blob
    <<~BLOB
      # frozen_string_literal: true

      class FetchUsers
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

  def self.pluralized_organizer_spec_blob
    <<~BLOB
      # frozen_string_literal: true

      require 'rails_helper'

      RSpec.describe FetchUsers, type: :organizer do
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

  def self.simple_organizer_blob
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

  def self.simple_organizer_spec_blob
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

  def self.advanced_organizer_blob
    <<~BLOB.chomp
      # frozen_string_literal: true

      module My::Fancy
        class Organizer
          extend ::LightService::Organizer

          def self.call(params)
            with(
              #foo: params[:foo],
              #bar: params[:bar]
            ).reduce(actions)
          end

          def self.actions
            [
              #My::Fancy::OneAction,
              #My::Fancy::TwoAction,
            ]
          end
        end
      end
    BLOB
  end

  def self.advanced_organizer_spec_blob
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
# rubocop:enable Metrics/ClassLength
