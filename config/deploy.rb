# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

lock '~> 3.4'

set :application, 'myapp'
set :repo_url, 'https://github.com/myorganization/myapp.git'

set :linked_files, %w{bundle/config .ruby-version}
set :config_files, %w{config/database.yml config/secrets.yml     config/puma.rb      config/fedora.yml
                      config/ezid.yml     config/blacklight.yml  config/solr.yml     config/zotero.yml
                      config/redis.yml    config/resque-pool.yml config/role_map.yml config/arkivo.yml
                      config/mcommunity.yml config/browse_everything_providers.yml}

set :linked_dirs,  %w{log bundle tmp/pids tmp/cache tmp/derivatives tmp/uploads
                      tmp/sockets vendor/bundle public/system public/uploads}

############## Most users should not need to set anything below this line. ##############

set :scm, :git
set :format, :pretty
set :pty, true
set :use_sudo, false
set :deploy_via, :remote_cache

set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_custom_path, '/l/local/rbenv'
set :rbenv_ruby, '2.3.0'
set :rbenv_type, :system
set :rbenv_prefix, ->{"RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"}

set :deploy_to, ->{ File.join fetch(:deploy_base), "#{fetch(:application)}-#{fetch(:stage)}" }
set :default_env, ->{ { 'HOME' => shared_path } }
set :bundle_path, ->{ shared_path.join('vendor/bundle') }

# Support multiple users running the deployment (not simultaneously though!!)
# Set umask so files are group writeable.
SSHKit.config.umask = '0002'

# Set :tmp_dir so multiple users can run the deployment
set :tmp_dir, File.join('/tmp', ENV['USER'] )

# Use branch from env if provided.
set :branch, ENV['branch'] || ask('Enter the deployment branch or tag:', 'master')

namespace :deploy do
  task :create_dirs do
    on roles(:web) do
      dirs = linked_dirs(shared_path) << File.join(shared_path, "config")
      dirs.each do |dir|
        execute :mkdir, '-p', dir
      end
    end
  end

  task :chmod_dirs do
    on roles(:web) do
      dirs = linked_dirs(shared_path) << File.join(shared_path, "config")
      dirs.each do |dir|
        if test :test, '-0', dir
          execute :chmod, '2775', dir
        end
      end
    end
  end

  task :chmod_linked_files do
    on roles(:web) do
      files = linked_files(shared_path)
      files.each do |file|
        if test :test, '-0', file
          execute :chmod, '0660', file
        end
      end
    end
  end

  task :chmod_assets do
    on roles(:web) do
      assets_dir = File.join(shared_path,"public","assets", "**")
      Dir.glob(assets_dir).each do |file|
        if test :test, '-0', file
          execute :chmod, '2775', file
        end
      end
    end
  end

  task :restart do
    on roles(:web) do
      # This has to be enabled using visudo on the server
      execute :sudo, '/bin/systemctl', 'restart', "app-puma@#{fetch(:application)}-#{fetch(:stage)}.service"
    end
  end

  before :starting, "linked_files:upload:files"
  before :starting, :create_dirs
  before :starting, :chmod_dirs
  after :updated, :chmod_assets
  after :finishing, :cleanup
  after :finishing, :restart

end

