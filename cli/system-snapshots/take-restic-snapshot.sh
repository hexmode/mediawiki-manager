#!/bin/bash

source ./envs/my-new-system.env

source ./cli/lib/utils.sh
source ./cli/lib/permissions.sh

######
# STEP 1: Dump database
printf "MWM snapshot: Trying to mysqldump mediawiki...\n"
containerExec $APACHE_CONTAINER_NAME bash -c \
  "mysqldump -h $MYSQL_HOST -u $MYSQL_USER -p$WG_DB_PASSWORD \
  $DATABASE_NAME > /var/www/html/w/db.sql"
printf "MWM snapshot: mysqldump mediawiki completed.\n"

######
# STEP 2: Run restic backup
printf "MWM snapshot: Trying to run restic backup...\n"
containerStart restic/restic "backup /data" \
               ./envs/my-new-system.env     \
               $MEDIAWIKI_ROOT/w:/data      \
               $SYSTEM_INSTANCE_ROOT/$RESTIC_REPOSITORY:/$RESTIC_REPOSITORY
printf "MWM snapshot: Completed running restic backup.\n"
