# frozen_string_literal: true

module RakeGit
  module Patches
    module GitLib
      def untracked_files
        command_lines('ls-files', %w[--others --exclude-standard])
      end
    end
  end
end
