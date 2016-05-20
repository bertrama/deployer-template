## Curation Concerns Based Application Deployment Project.
A project "myapp" is hosted publicly.  The deployment and sensitive configs are hosted on a private owned server in a corresponding project "myapp-deployer".
The intended use of this is to serve as a template for the deployer projects.

### Use and Deviations from Capistrano Standard Practices
Sometimes there are mutliple "production" deployment targets with different configs. For instance, the EZID configuation for the staging target uses the testing credentials
for minting DOIs.  In this way, the staging deployment interacts with the external EZID service, but the minted DOIs are only around for two weeks.
This also means that the actual production deployment configs aren't getting put on the staging, testing, or other tagets which may have different security levels.

The `upload` directory contains all the files that should eventually end up on a target machine instead of those directories being at the base level of the project. 

* `upload/etc/systemd/system ` contains the systemd service templates and drop in configs.
* The `<target>-config/` directories under `upload/` are the config directories for the respective deployment target.
  * `upload/staging-config/` maps to shared/config on the staging target.
  * `upload/production-config/` maps to shared/config on the production target.

## One time setup for server
* set up ssh keys for deploying users.
* create logging directory for apache logs e.g. `/var/log/apache2/myapp-staging/`
* create directory for the minter-statefile
  * This needs to match the environment variable set in the systemd drop-in conf
  * e.g. `/var/myapp/myapp-staging/` or `/var/productionname/`
* create database using utf8 as the default charset
  * e.g. `CREATE DATABASE mydb DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;`
* grant permissions to application database user on the database.
* setup solr
  * copy solr core template and make sure name, port, and host jive with app config.
* setup fedora
* setup systemd services
  * See section on systemd services
  * `rsync -urz upload/etc/systemd/system target_host:/etc/systemd/system`
  * Enable the target services (so they come up after restart)
    * e.g. `systemctl enable resque-pool@myapp-staging.service`
* add deploying user and running user to common group.  i.e. the group of the running user.
  * `usermod -a -G groupname username`
* add deploying user to sudoers
  * e.g. `%dlps  ALL=(root) NOPASSWD: /bin/systemctl restart app-cc-puma@myapp-staging.service`

## One time pre-capistrano setup.
in app/shared/ directory:
* create bundle/
* create config/
* create linked directories: log tmp/pids tmp/cache tmp/sockets tmp/derivatives tmp/uploads vendor/bundle public/system public/system/avatars public/uploads
* rsync contents of upload/config to shared/config on target in order to seed the shared config directory
* the deploying user and the running user have to be part of the same group. e.g. myapp
* the directories of the application directory have to belong to the user that runs the application (i.e. myapp)
  * the deploy user has to belong to the same group as the running user.
  * group ownership of the directories has to be the shared group.
  * chown -R myapp:myapp /hydra-dev/myapp-staging/app

## Gotchas
* pidfile config in `puma.rb` must match systemd `app-<myapp_target>.service` pidfile.
* myapp user needs to have fits.sh in PATH for non-login sessions. This was done by adding a .bashrc to the HOME dir for the user. (Alternatively, can hardcode path to fits in application)
* For loading datasets from the command line, the user running populate rake task will need write access to the minter-statefile.

## Systemd Services
* Using systemd service templates. The supplied instance corresponds to the app and target. e.g. `myapp-production` or `myapp-staging`
* Startup should be of the form `systemctl app-cc-puma@myapp-production.service` which will start the corresponding rescue pool.
* *Need to configure the service and other environment vars using a drop-in conf file.*
