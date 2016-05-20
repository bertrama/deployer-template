require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/rails'
require 'capistrano/linked_files'

require 'net/ssh/kerberos'
set :ssh_options, { :auth_methods => %w(gssapi-with-mic publickey hostbased password keyboard-interactive) }


Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
