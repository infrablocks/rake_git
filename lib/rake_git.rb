# frozen_string_literal: true

require 'rake_git/tasks'
require 'rake_git/version'

require 'rake_git/patches/git_lib'

Git::Lib.prepend(RakeGit::Patches::GitLib)

module RakeGit
  def self.define_commit_task(opts = {}, &)
    RakeGit::Tasks::Commit.define(opts, &)
  end
end
