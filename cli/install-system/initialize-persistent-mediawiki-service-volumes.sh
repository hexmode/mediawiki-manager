#!/bin/bash

topDir=`git rev-parse --show-toplevel`
source $topDir/cli/lib/utils.sh

# This script is used in the context of https://mwstake.org/mwstake/wiki/MWStake_MediaWiki_Manager#ALcontainerization:_Docker

MWM_MEDIAWIKI_CONTAINER_ID=$(containerStart run \
  dataspects/mediawiki:1.35.0-2103040820)
declare -a vols=(
  "/var/www/html/w/LocalSettings.php"
  "/var/www/html/w/extensions"
  "/var/www/html/w/skins"
  "/var/www/html/w/vendor"
  "/var/www/html/w/composer.json"
)
for vol in "${vols[@]}"
do
  containerCopyFrom $MWM_MEDIAWIKI_CONTAINER_ID $vol $MEDIAWIKI_ROOT/w
done
containerStop $MWM_MEDIAWIKI_CONTAINER_ID

# FIXME
sudo chmod -R 777 $MEDIAWIKI_ROOT/w

echo "Initialized persistent mediawiki service volumes"
