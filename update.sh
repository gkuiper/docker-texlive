#!/bin/bash
set -eo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

# sort version numbers with highest first
IFS=$'\n'; versions=( $(echo "${versions[*]}" | sort -rV) ); unset IFS

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
		
	if [ "$version" -le 2015 ]; then
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

VOLUME ["/data"]
EOD
	else
			cat >> "$version/Dockerfile" <<EOD
RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \\
  && wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz.sha512 \\
  && sha512sum -c install-tl-unx.tar.gz.sha512 \\
  && tar xzvf install-tl-unx.tar.gz \\
  && ./install-tl-*/install-tl -profile /texlive.profile \\
  && rm -rf install-tl-*

VOLUME ["/data"]
EOD
	fi
done
