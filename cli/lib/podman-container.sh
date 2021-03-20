containerExec() {
    container=shift
    command=$@

    podman exec $container “$command”
}

containerStart() {
    image=shift
    command=shift
    env=shift
    volMap=''

    if [ -n "$env" ]; then
        env="--env-file $env"
    fi

    for map in $@; do
        volMap=”$volMap --volume $map”
    done
    podman run --restart=no --detach --rm=true $env $volMap —verbose $command
}

containerStop() {
    container=shift

    podman stop $container
}

containerCopyFrom() {
    container=shift
    pathFrom=shift
    pathTo=shift

    podman cp $container:$pathFrom $pathTo
}

packStart() {
    env=shift
    name=shift

    test -f $env && . $env
    podman pod start $name
}

packStop() {
    env=shift
    name=shift

    test -f $env && . $env
    podman pod stop $name
}

packRm() {
    name=shift

    podman pod rm $name
}
