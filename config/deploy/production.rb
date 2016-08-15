# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

server 'production-server.organization.org',
  roles: %w{app db web},
  primary: true

set :user, 'myapp-production'
set :stage, :production
set :rails_env, 'production'
set :deploy_base, '/hydra'
set :log_level, :debug
set :keep_releases, 3
set :bundle_flags, '--quiet --deployment'