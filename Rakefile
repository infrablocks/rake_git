# frozen_string_literal: true

require 'yaml'
require 'rake_circle_ci'
require 'rake_git_crypt'
require 'rake_github'
require 'rake_ssh'
require 'rake_gpg'
require 'securerandom'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: %i[
  library:fix
  test:unit
]

RakeGitCrypt.define_standard_tasks(
  namespace: :git_crypt,

  provision_secrets_task_name: :'secrets:provision',
  destroy_secrets_task_name: :'secrets:destroy',

  install_commit_task_name: :'git:commit',
  uninstall_commit_task_name: :'git:commit',

  gpg_user_key_paths: %w[
    config/gpg
    config/secrets/ci/gpg.public
  ]
)

namespace :encryption do
  namespace :directory do
    desc 'Ensure CI secrets directory exists.'
    task :ensure do
      FileUtils.mkdir_p('config/secrets/ci')
    end
  end

  namespace :passphrase do
    desc 'Generate encryption passphrase used by CI.'
    task generate: ['directory:ensure'] do
      File.write('config/secrets/ci/encryption.passphrase',
                 SecureRandom.base64(36))
    end
  end
end

namespace :keys do
  namespace :deploy do
    RakeSSH.define_key_tasks(
      path: 'config/secrets/ci/',
      comment: 'maintainers@infrablocks.io'
    )
  end

  namespace :gpg do
    RakeGPG.define_generate_key_task(
      output_directory: 'config/secrets/ci',
      name_prefix: 'gpg',
      owner_name: 'InfraBlocks Maintainers',
      owner_email: 'maintainers@infrablocks.io',
      owner_comment: 'rake_git CI Key'
    )
  end
end

namespace :secrets do
  desc 'Generate all generatable secrets.'
  task generate: %w[
    encryption:passphrase:generate
    keys:deploy:generate
    keys:gpg:generate
  ]

  desc 'Provision all secrets.'
  task provision: [:generate]

  desc 'Delete all secrets.'
  task :destroy do
    rm_rf 'config/secrets'
  end

  desc 'Rotate all secrets.'
  task rotate: [:'git_crypt:reinstall']
end

namespace :git do
  desc 'Commit all changes'
  task :commit, [:message] do |_, args|
    sh('git', 'add', '-A')
    sh('git', 'commit', '-m', args.message)
  end
end

RuboCop::RakeTask.new

namespace :library do
  desc 'Run all checks of the library'
  task check: [:rubocop]

  desc 'Attempt to automatically fix issues with the library'
  task fix: [:'rubocop:autocorrect_all']
end

namespace :test do
  RSpec::Core::RakeTask.new(:unit)
end

RakeCircleCI.define_project_tasks(
  namespace: :circle_ci,
  project_slug: 'github/infrablocks/rake_git'
) do |t|
  circle_ci_config =
    YAML.load_file('config/secrets/circle_ci/config.yaml')

  t.api_token = circle_ci_config['circle_ci_api_token']
  t.environment_variables = {
    ENCRYPTION_PASSPHRASE:
        File.read('config/secrets/ci/encryption.passphrase')
            .chomp
  }
  t.checkout_keys = []
  t.ssh_keys = [
    {
      hostname: 'github.com',
      private_key: File.read('config/secrets/ci/ssh.private')
    }
  ]
end

RakeGithub.define_repository_tasks(
  namespace: :github,
  repository: 'infrablocks/rake_git'
) do |t, args|
  github_config =
    YAML.load_file('config/secrets/github/config.yaml')

  t.access_token = github_config['github_personal_access_token']
  t.deploy_keys = [
    {
      title: 'CircleCI',
      public_key: File.read('config/secrets/ci/ssh.public')
    }
  ]
  t.branch_name = args.branch_name
  t.commit_message = args.commit_message
end

namespace :pipeline do
  desc 'Prepare CircleCI Pipeline'
  task prepare: %i[
    circle_ci:env_vars:ensure
    circle_ci:checkout_keys:ensure
    circle_ci:ssh_keys:ensure
    github:deploy_keys:ensure
  ]
end

namespace :version do
  desc 'Bump version for specified type (pre, major, minor, patch)'
  task :bump, [:type] do |_, args|
    bump_version_for(args.type)
  end
end

desc 'Release gem'
task :release do
  sh 'gem release --tag --push'
end

def bump_version_for(version_type)
  sh "gem bump --version #{version_type} " \
     '&& bundle install ' \
     '&& export LAST_MESSAGE="$(git log -1 --pretty=%B)" ' \
     '&& git commit -a --amend -m "${LAST_MESSAGE} [ci skip]"'
end
