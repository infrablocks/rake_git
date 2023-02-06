# frozen_string_literal: true

require 'rake_git/tasks'
require 'rake_git/version'

module RakeGit
  def self.define_commit_task(opts = {}, &block)
    RakeGit::Tasks::Commit.define(opts, &block)
  end
end
