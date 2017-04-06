#!/bin/bash
set -eu

username=( guusk )
image=( docker-texlive )

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

# sort version numbers with highest first
IFS=$'\n'; versions=( $(echo "${versions[*]}" | sort -rV) ); unset IFS

for version in "${versions[@]}"; do
    echo "Building $username/$image:$version"; 
    docker build -t $username/$image:$version $version/;
done

