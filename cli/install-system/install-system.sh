#!/bin/bash

# FIXME: handle multiple system setups
source ./envs/my-new-system.env

##################
# SOURCE CLI LIB #
##################

source ./cli/lib/utils.sh
source ./cli/lib/permissions.sh

##############
# INITIALIZE #
##############

initializeSystemLog

###########
# GENERAL #
###########

# Initialize MediaWiki script path
mkdir --parents $MEDIAWIKI_ROOT/w
writeToSystemLog "Initialized: $MEDIAWIKI_ROOT"

### >>>
# MWM Concept: initialize persistent mediawiki service volumes
source ./cli/install-system/initialize-persistent-mediawiki-service-volumes.sh
# <<<

podman play kube mediawiki-manager.yml

# setPermissionsOnSystemInstanceRoot

##################
# DOCKER COMPOSE #
##################

echo "Start pod..."
./cli/manage-system/stop.sh
./cli/manage-system/start.sh
writeToSystemLog "Started: pod"

#############
# MEDIAWIKI #
#############

echo "Set domain name..."
addToLocalSettings "\$wgServer = 'https://$SYSTEM_DOMAIN_NAME:4443';"

echo "Configure database access..."
addToLocalSettings "\$wgDBpassword = '$WG_DB_PASSWORD';"
addToLocalSettings "\$wgDBserver = '$MYSQL_HOST';"

removeFromLocalSettings "/\$wgSiteNotice = '================ MWM Safe Mode ================';/d"

# setPermissionsOnSystemInstanceRoot

source ./cli/lib/waitForMariaDB.sh

echo "Create database and user..."
containerExec $APACHE_CONTAINER_NAME bash -c \
  "mysql -h $MYSQL_HOST -u root -p$MARIADB_ROOT_PASSWORD \
  -e \" CREATE DATABASE $DATABASE_NAME;
        CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$WG_DB_PASSWORD';
        GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO '$MYSQL_USER'@'%';
        FLUSH PRIVILEGES;\""

echo "Import database..."
containerExec $APACHE_CONTAINER_NAME /bin/bash -c \
  "mysql -h $MYSQL_HOST -u $MYSQL_USER -p$WG_DB_PASSWORD \
  mediawiki < /var/www/html/w/db.sql"

runMWUpdatePHP

###############################
# Done installing core system #
###############################

echo "Inject contents..."
source ./cli/manage-content/inject-local-WikiPageContents.sh
source ./cli/manage-content/inject-manage-page-from-mediawiki.org.sh

##########
# RESTIC #
##########

echo "Initialize restic backup repository"
containerExec $APACHE_CONTAINER_NAME /bin/bash -c \
  "restic --password-file /var/www/restic_password --verbose init --repo /var/www/html/restic-repo"

### >>>
# MWM Concept: take initial snapshot and view snapshots
source ./cli/system-snapshots/take-restic-snapshot.sh
source ./cli/system-snapshots/view-restic-snapshots.sh
# <<<

# setPermissionsOnSystemInstanceRoot
