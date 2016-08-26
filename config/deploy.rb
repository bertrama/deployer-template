# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

lock '~> 3.4'

set :application, 'myapp'
set :repo_url, 'https://github.com/myorganization/myapp.git'
set :scm, :git
set :format, :pretty
set :pty, true
set :use_sudo, false
set :deploy_via, :remote_cache
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

# Support multiple users running the deployment (not simultaneously though!!)
# Set umask so files are group writeable.
SSHKit.config.umask = '0002'
# Set :tmp_dir so multiple users can run the deplyment
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

  before :starting, :create_dirs
  before :starting, :chmod_dirs
  after :updated, :chmod_assets

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
