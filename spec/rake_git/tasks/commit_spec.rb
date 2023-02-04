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
    define_task

    expect(Rake.application)
      .to(have_task_defined('git:commit'))
  end

  it 'gives the task a description' do
    define_task

    expect(Rake::Task['git:commit'].full_comment)
      .to(eq('Produce a commit on the current branch.'))
  end

  it 'allows multiple commit tasks to be declared' do
    define_task(namespace: :git1)
    define_task(namespace: :git2)

    expect(Rake.application).to(have_task_defined('git1:commit'))
    expect(Rake.application).to(have_task_defined('git2:commit'))
  end
end
