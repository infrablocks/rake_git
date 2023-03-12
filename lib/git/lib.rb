# frozen_string_literal: true

require 'git'

module Git
  class Lib
    def untracked_files
      command_lines('ls-files', %w[--others --exclude-standard])
    end
  end
end
