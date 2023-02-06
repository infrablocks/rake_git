# frozen_string_literal: true

require 'spec_helper'

describe RakeGit::Tasks::Commit do
  include_context 'rake'

  def define_task(opts = {}, &block)
    opts = { namespace: :git }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a commit task in the namespace in which it is created' do
    define_task(message: 'Add important stuff.')

    expect(Rake.application)
      .to(have_task_defined('git:commit'))
  end

  it 'gives the task a description' do
    define_task(message: 'Add important stuff.')

    expect(Rake::Task['git:commit'].full_comment)
      .to(eq('Commit changes to git.'))
  end

  it 'allows multiple commit tasks to be declared' do
    define_task(namespace: :git1)
    define_task(namespace: :git2)

    expect(Rake.application).to(have_task_defined('git1:commit'))
    expect(Rake.application).to(have_task_defined('git2:commit'))
  end

  describe 'by default' do
    it 'stages all tracked files' do
      define_task(message: 'Add important stuff.')

      stub_output
      git_base = stub_git(
        path: '.',
        added: %w[added/file1 added/file2],
        changed: %w[changed/file1 changed/file2],
        deleted: %w[deleted/file1 deleted/file2]
      )

      Rake::Task['git:commit'].invoke

      expect(git_base)
        .to(have_received(:add)
              .with(a_collection_containing_exactly(
                      'added/file1', 'added/file2',
                      'changed/file1', 'changed/file2',
                      'deleted/file1', 'deleted/file2'
                    ),
                    all: true))
    end

    it 'stages all untracked files' do
      define_task(message: 'Add important stuff.')

      stub_output
      git_base = stub_git(
        path: '.',
        untracked: %w[untracked/file1 untracked/file2]
      )

      Rake::Task['git:commit'].invoke

      expect(git_base)
        .to(have_received(:add)
              .with(a_collection_containing_exactly(
                      'untracked/file1', 'untracked/file2'
                    ),
                    all: true))
    end

    it 'creates a commit using the provided message' do
      define_task(message: 'Add important stuff.')

      stub_output
      git_base = stub_git(
        path: '.'
      )

      Rake::Task['git:commit'].invoke

      expect(git_base)
        .to(have_received(:commit)
              .with('Add important stuff.'))
    end
  end

  describe 'when message provided through argument' do
    it 'uses the message configured via arguments' do
      define_task(argument_names: [:message]) do |t, args|
        t.message = args.message
      end

      stub_output
      git_base = stub_git(
        path: '.'
      )

      Rake::Task['git:commit'].invoke('Message in argument.')

      expect(git_base)
        .to(have_received(:commit)
              .with('Message in argument.'))
    end
  end

  def stub_output
    # rubocop:disable RSpec/AnyInstance
    %i[print puts].each do |method|
      allow_any_instance_of(Kernel).to(receive(method))
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
    # rubocop:enable RSpec/AnyInstance
  end

  def stub_git(opts)
    path = opts[:path]

    git_base = stub_git_base(opts)

    allow(Git)
      .to(receive(:open)
            .with(path)
            .and_return(git_base))

    git_base
  end

  def stub_git_base(opts)
    git_status = stub_git_status(opts)

    git_base = instance_double(Git::Base)
    allow(git_base).to(receive(:status).and_return(git_status))
    allow(git_base).to(receive(:add))
    allow(git_base).to(receive(:commit))

    git_base
  end

  def stub_git_status(opts)
    instance_double(
      Git::Status,
      added: to_status_file_hash(opts[:added] || []),
      changed: to_status_file_hash(opts[:changed] || []),
      deleted: to_status_file_hash(opts[:deleted] || []),
      untracked: to_status_file_hash(opts[:untracked] || [])
    )
  end

  def stub_git_status_file
    instance_double(Git::Status::StatusFile)
  end

  def to_status_file_hash(paths)
    paths.inject({}) { |acc, path| acc.merge(path => stub_git_status_file) }
  end
end
