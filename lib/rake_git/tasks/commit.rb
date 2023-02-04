# frozen_string_literal: true

require 'rake_factory'

module RakeGit
  module Tasks
    class Commit < RakeFactory::Task
      default_name :commit
      default_description 'Produce a commit on the current branch.'

      action do
        puts('Committing...')
      end
    end
  end
end
