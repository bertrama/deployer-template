environment 'production'
threads 1, 4
# Bind to the private network address
# Use tcp as the http server (apache) is on a different host.
bind 'tcp://localhost:30060'

pidfile '/hydra-dev/myapp-staging/shared/log/myapp-puma.pid'

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
