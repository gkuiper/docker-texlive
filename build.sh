#!/bin/bash
set -eu

username=( guusk )
image=( docker-texlive )

versions=( */ )
versions=( "${versions[@]%/}" )

# sort version numbers with highest first
IFS=$'\n'; versions=( $(echo "${versions[*]}" | sort -rV) ); unset IFS

for version in "${versions[@]}"; do
    echo "Building $username/$image:$version"; 
    docker build -t $username/$image:$version $version/;
done

