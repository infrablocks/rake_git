# frozen_string_literal: true

require 'rake_factory'
require 'git'

module RakeGit
  module Tasks
    class Commit < RakeFactory::Task
      default_name :commit
      default_description 'Commit changes to git.'

      parameter :message, required: true

      parameter :stage_tracked_files, default: true
      parameter :stage_untracked_files, default: true

      parameter :working_directory, default: '.'

      action do
        puts('Committing changes to git...')
        base = Git.open(working_directory)

        maybe_stage_tracked_files(base)
        maybe_stage_untracked_files(base)
        commit(base)
      end

      private

      def maybe_stage_tracked_files(base)
        return unless stage_tracked_files

        status = base.status
        base.add(
          [
            *status.added.keys,
            *status.changed.keys,
            *status.deleted.keys
          ],
          all: true
        )
      end

      def maybe_stage_untracked_files(base)
        return unless stage_untracked_files

        status = base.status
        base.add(status.untracked.keys, all: true)
      end

      def commit(base)
        base.commit(message)
      end
    end
  end
end
