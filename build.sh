#!/bin/bash
set -ex

USERNAME=guusk
IMAGE=docker-texlive

for i in $(ls -d */); do 
    echo "Building $USERMAGE/$IMAGE:${i%%/}"; 
    docker build -t $USERNAME/$IMAGE:${i%%/} $i;
done

