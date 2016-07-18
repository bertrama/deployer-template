## Deployment Project Template
A deployment project contains the deployment logic and sensitive information for a corresponding project.  e.g myapp and myapp-deploy.
The repo for "myapp" can be public while the "myapp-deploy" repo is housed on a private server.  This is an alternative to vaults for sensitive config.
This project is a template for the "-deploy" projects.

## Use
### Making a -deploy template for myapp
1. Make a bare git repo to serve as the remote on your private server.
```sh
git clone --bare https://github.com/mlibrary/deployer-template.git myapp-deploy.git
```
2. Clone a working copy your myapp-deploy repo. 
```sh
git clone ssh://priv.institution.org/path/to/myapp-deploy.git
```
3. Make required changes in capistrano deployment files
TODO: list required changes, myapp -> project name, etc.

### Using the deployment template.
1. Change into the myapp-deploy directory
2. Run `bundle install --path=.bundle` to install gems (vendorized)
3. Run `bundle exec cap <stage> deploy` to deploy the stage (e.g. testing, staging, training)

### Use and Deviations from Capistrano Standard Practices
Sometimes there are mutliple "production" deployment targets with different configs. For instance, the EZID configuation for the staging target uses the testing credentials
for minting DOIs.  In this way, the staging deployment interacts with the external EZID service, but the minted DOIs are only around for two weeks.
This also means that the actual production deployment configs aren't getting put on the staging, testing, or other tagets which may have different security levels.

The `upload` directory contains all the files that should eventually end up on a target machine instead of those directories being at the base level of the project. 

* `upload/etc/systemd/system ` contains the systemd service templates and drop in configs.
* The `<target>-config/` directories under `upload/` are the config directories for the respective deployment target.
  * `upload/staging-config/` maps to shared/config on the staging target.
  * `upload/production-config/` maps to shared/config on the production target.
  
## Double check your configs.
* Make sure name, port, and host jive with app config.
* Make sure credentials for external dependencies (db, solr, fedora, etc.) are working.

### One time setup provided by ansible-predeploy run my sysadmin
The following should be provisioned prior to trying to deploy the application:
* set up ssh keys for deploying users.
* create logging directory for apache logs e.g. `/var/log/apache2/myapp-staging/`
* create directory for the minter-statefile
  * This needs to match the environment variable set in the systemd drop-in conf
  * e.g. `/var/local/myapp-staging/`
* create database using utf8 as the default charset
  * e.g. `CREATE DATABASE mydb DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;`
* grant permissions to application database user on the database.
* setup solr
  * copy solr core template
* setup systemd services
  * See section on systemd services
  * `rsync -urz upload/etc/systemd/system target_host:/etc/systemd/system`
  * Enable the target services (so they come up after restart)
    * e.g. `systemctl enable resque-pool@myapp-staging.service`
* add deploying user and running user to common group.  i.e. the group of the running user.
  * `usermod -a -G groupname username`
* add deploying user to sudoers
  * e.g. `%dlps  ALL=(root) NOPASSWD: /bin/systemctl restart app-puma@myapp-staging.service`

## Gotchas
* pidfile config in `puma.rb` must match systemd `app-<myapp_target>.service` pidfile.
* myapp user needs to have fits.sh in PATH for non-login sessions. This was done by adding a drop in conf to the systemd service with a hard coded path.
* For loading datasets from the command line, the user running populate rake task will need write access to the minter-statefile.

## Systemd Services
* Using systemd service templates. The supplied instance corresponds to the app and target. e.g. `myapp-production` or `myapp-staging`
* Startup should be of the form `systemctl app-puma@myapp-production.service` which will start the corresponding rescue pool.
* Other config and environment vars can be done using a drop-in conf file. *This needs to be reviewed and added manually.*
