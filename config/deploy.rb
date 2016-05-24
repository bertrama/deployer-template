# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

lock '~> 3.4'

# Set umask so files are group writeable.
SSHKit.config.umask = '0002'

set :application, 'myapp'
set :repo_url, 'https://github.com/myorganization/myapp.git'
set :scm, :git
set :format, :pretty
set :pty, true
set :use_sudo, false
set :deploy_via, :remote_cache
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

# Use branch from env if provided.
set :branch, ENV['branch'] || ask('Enter the deployment branch or tag:', 'master')

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

namespace :puma do
  task :start do
    on roles (fetch(:puma_role)) do |role|
      execute 'sudo', 'systemctl', 'restart', 'app-myapp'
    end
  end
end

