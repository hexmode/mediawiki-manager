#!/bin/bash

topDir=`git rev-parse --show-toplevel`
source $topDir/cli/lib/utils.sh

packStop - mwm
