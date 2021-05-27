#!/bin/bash

CWD=$(dirname "$(readlink -f "$0")")
USERNAME=konkeydong
IMAGE=${USERNAME}/ruby:latest
VOLUME=-v\ "$(pwd):/usr/src/app"

build()
{
    docker build -t ${IMAGE} .
}

exec()
{
    docker run -it ${VOLUME} ${IMAGE} /bin/bash
}

download_ost()
{
    docker run -it ${VOLUME} ${IMAGE} /bin/bash -c "cd game_ost ; ruby download.rb url_list.txt"
}

push()
{
    docker push ${IMAGE}
}

pull()
{
    docker pull ${IMAGE}
}

help()
{
    cat << EOF
    build:     Build the docker image named "lua:latest"
    exec:      Exec into a container for direct interaction.
    run_tests: Run lua unit tests.
    help:      Display this help screen and exit.
    push:      Push image to Docker Hub.
    pull:      Pull image from Docker Hub.
EOF

    exit 0
}

eval $@
