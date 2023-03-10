# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RakeGit do
  it 'has a version number' do
    expect(RakeGit::VERSION).not_to be_nil
  end

  describe 'define_commit_task' do
    context 'when instantiating RakeGit::Tasks::Commit' do
      it 'passes the provided block' do
        opts = {
          argument_names: [:message]
        }

        block = lambda do |t, args|
          t.message = args.message
        end

        allow(RakeGit::Tasks::Commit).to(receive(:define))

        described_class.define_commit_task(opts, &block)

        expect(RakeGit::Tasks::Commit)
          .to(have_received(:define) do |passed_opts, &passed_block|
            expect(passed_opts).to(eq(opts))
            expect(passed_block).to(eq(block))
          end)
      end
    end
  end
end
