# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

server 'production-server.organization.org',
  roles: %w{app db web},
  primary: true

set :user, 'myapp-production'
set :stage, :production
set :branch, 'master'
set :rails_env, 'production'
set :deploy_to, '/hydra/myapp-production'
set :default_env, { 'HOME' => '/hydra/myapp-production/shared'}
set :log_level, :debug
set :keep_releases, 3
set :rbenv_custom_path, '/l/local/rbenv'
set :rbenv_ruby, '2.3.0'
set :rbenv_type, :system
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

set :linked_files, %w{bundle/config .ruby-version} 
set :config_files, %w{config/database.yml config/secrets.yml     config/puma.rb      config/fedora.yml
                      config/ezid.yml     config/blacklight.yml  config/solr.yml     config/zotero.yml
                      config/redis.yml    config/resque-pool.yml config/role_map.yml config/arkivo.yml
                      config/mcommunity.yml config/browse_everything_providers.yml}

set :linked_dirs,  %w{log bundle tmp/pids tmp/cache tmp/derivatives tmp/uploads tmp/sockets vendor/bundle public/system public/uploads}

set :bundle_path, -> { shared_path.join('vendor/bundle') }
set :bundle_flags, '--quiet --deployment'

namespace :deploy do
  task :restart do
    on roles(:web) do
      # This has to be enabled using visudo on the server
      execute :sudo, '/bin/systemctl', 'restart', 'app-puma@myapp-production.service'
    end
  end

  # Set the stage so config_files gets the correct stage
  before :starting, "linked_files:upload:files"
  after :finishing, :compile_assets
  after :finishing, :cleanup
  after :finishing, :restart
end
