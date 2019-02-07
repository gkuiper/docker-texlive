#
# THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM debian:jessie
MAINTAINER Guus Kuiper <guuskuiper@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

#Build dependencies
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    wget perl perl-tk fontconfig libwww-perl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
    
#Configuration
COPY texlive.profile /
WORKDIR /data
ENV TEXLIVE_VERSION 2018
ENV TEXDIR /usr/local/texlive/$TEXLIVE_VERSION
ENV TEXMFCONFIG /data/.texlive$TEXLIVE_VERSION/texmf-config
ENV TEXMFHOME /data/texmf
ENV TEXMFLOCAL /usr/local/texlive/texmf-local
ENV TEXMFSYSCONFIG /usr/local/texlive/$TEXLIVE_VERSION/texmf-config
ENV TEXMFSYSVAR /usr/local/texlive/$TEXLIVE_VERSION/texmf-var
ENV TEXMFVAR /data/.texlive$TEXLIVE_VERSION/texmf-var

            
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
  
RUN URL="$(curl -sILw '%{url_effective}' http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -o /dev/null)" && echo $URL \
  && wget $URL \
  && wget $URL.sha512 \
  && sha512sum -c install-tl-unx.tar.gz.sha512 \
  && tar xzvf install-tl-unx.tar.gz \
  && ./install-tl-*/install-tl -profile /texlive.profile \
  && rm -rf install-tl-*

ENV PATH="${TEXDIR}/bin/x86_64-linux:${PATH}"

VOLUME ["/data"]
