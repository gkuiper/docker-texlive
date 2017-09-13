#!/bin/bash
set -eo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
all_versions=( */ )
if [ ${#versions[@]} -eq 0 ]; then
    versions=("${all_versions[@]}")
fi
echo "versions: ${versions[@]}"
versions=( "${versions[@]%/}" )
echo "versions: ${versions[@]}"
all_versions=( "${all_versions[@]%/}" )
IFS=$'\n'; latest=( $(echo "${all_versions[*]}" | sort -rV | head -1) ); unset IFS
echo "versions: ${versions[@]}"
echo "latest: $latest"

# sort version numbers with highest first
IFS=$'\n'; versions=( $(echo "${versions[*]}" | sort -rV) ); unset IFS
echo "versions: ${versions[@]}"

for version in "${versions[@]}"; do
	echo "$version"
	cat > "$version/Dockerfile" <<EOD
#
# THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM debian:jessie
MAINTAINER Guus Kuiper <guuskuiper@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

#Build dependencies
RUN apt-get update \\
  && apt-get install --no-install-recommends -y \\
    wget perl perl-tk fontconfig libwww-perl \\
  && apt-get clean \\
  && rm -rf /var/lib/apt/lists/*
    
#Configuration
COPY texlive.profile /
WORKDIR /data
ENV TEXLIVE_VERSION $version
ENV TEXDIR /usr/local/texlive/\$TEXLIVE_VERSION
ENV TEXMFCONFIG /data/.texlive\$TEXLIVE_VERSION/texmf-config
ENV TEXMFHOME /data/texmf
ENV TEXMFLOCAL /usr/local/texlive/texmf-local
ENV TEXMFSYSCONFIG /usr/local/texlive/\$TEXLIVE_VERSION/texmf-config
ENV TEXMFSYSVAR /usr/local/texlive/\$TEXLIVE_VERSION/texmf-var
ENV TEXMFVAR /data/.texlive\$TEXLIVE_VERSION/texmf-var

EOD
		
#old versions use sha256, from 2016 sha512
	if [ "$version" -le "2015" ]; then
			sha256=$(curl -s "ftp://tug.org/historic/systems/texlive/$version/tlnet-final/install-tl-unx.tar.gz.sha256" | cut -d' ' -f1)
			echo "$version: $sha256"
			cat >> "$version/Dockerfile" <<EOD
ENV TEXLIVE_SHA256 $sha256
RUN wget ftp://tug.org/historic/systems/texlive/\$TEXLIVE_VERSION/tlnet-final/install-tl-unx.tar.gz \\
  && echo "\$TEXLIVE_SHA256 install-tl-unx.tar.gz" | sha256sum -c \\
  && tar xzvf install-tl-unx.tar.gz \\
  && ./install-tl-*/install-tl -profile /texlive.profile \\
  -repository ftp://tug.org/historic/systems/texlive/\$TEXLIVE_VERSION/tlnet-final \\
  && rm -rf install-tl-*
EOD
	elif [ "$version" -lt "$latest" ]; then
			sha512=$(curl -s "ftp://tug.org/historic/systems/texlive/$version/tlnet-final/install-tl-unx.tar.gz.sha512" | cut -d' ' -f1)
			echo "$version: $sha512"
			cat >> "$version/Dockerfile" <<EOD
ENV TEXLIVE_SHA512 $sha512
RUN wget ftp://tug.org/historic/systems/texlive/\$TEXLIVE_VERSION/tlnet-final/install-tl-unx.tar.gz \\
  && echo "\$TEXLIVE_SHA512 install-tl-unx.tar.gz" | sha512sum -c \\
  && tar xzvf install-tl-unx.tar.gz \\
  && ./install-tl-*/install-tl -profile /texlive.profile \\
  -repository ftp://tug.org/historic/systems/texlive/\$TEXLIVE_VERSION/tlnet-final \\
  && rm -rf install-tl-*
EOD
	else
#each mirror can have a slightly different version and sha, so dont include the hash in the Dockerfile
			cat >> "$version/Dockerfile" <<EOD
            
RUN apt-get update \\
  && apt-get install --no-install-recommends -y \\
    curl \\
  && apt-get clean \\
  && rm -rf /var/lib/apt/lists/*
  
RUN URL="\$(curl -sILw '%{url_effective}' http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -o /dev/null)" && echo \$URL \\
  && wget \$URL \\
  && wget \$URL.sha512 \\
  && sha512sum -c install-tl-unx.tar.gz.sha512 \\
  && tar xzvf install-tl-unx.tar.gz \\
  && ./install-tl-*/install-tl -profile /texlive.profile \\
  && rm -rf install-tl-*
EOD
	fi
	cat >> "$version/Dockerfile" <<EOD

ENV PATH="\${TEXDIR}/bin/x86_64-linux:\${PATH}"

VOLUME ["/data"]
EOD
done
