#!/bin/bash

source ./CanastaInstanceSettings.env

sudo docker run \
  --env-file ./CanastaInstanceSettings.env \
  --volume $CANASTA_INSTANCE_ROOT/$RESTIC_REPOSITORY:/$RESTIC_REPOSITORY \
  restic/restic \
  --verbose snapshots