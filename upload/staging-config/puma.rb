environment 'production'
threads 1, 4
# Bind to the private network address
# Use unix sockets if the http server is on the same host.
# bind "unix:///tmp/umrdr-staging.socket"
# Use tcp as the http server (apache) is on a different host.
bind 'tcp://10.255.255.255:30060'

pidfile '/hydra/myapp/app/shared/log/myapp-puma.pid'

on_restart do
# Code to run before doing a restart. This code should
# close log files, database connections, etc.
end

workers 4
worker_timeout 120
on_worker_boot do
  # Code to run when a worker boots to setup the process before booting
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
end

preload_app!
