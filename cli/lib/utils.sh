#!/bin/bash

OPTION_INSECURE=--insecure
cookie_jar="wikicj"
folder="/tmp"

getPageData () {
    PAGENAME=$(sed -r 's/.*\/(.*).wikitext/\1/g' <<< $1)
    WIKITEXT=`cat "$1"`
}

initializeSystemLog () {
    mkdir --parents logs
    rm ./logs/system.log
    touch ./logs/system.log
}

writeToSystemLog () {
    # TODO: fix timestamp
    echo $(date "+%Y-%m-%d") $1>> ./logs/system.log
}

addToLocalSettings () {
    echo $1>> mediawiki_root/w/LocalSettings.php
    writeToSystemLog "Written to system.log: $1"
}

promptToContinue () {
    read -p "Continue? (y/n)" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
}