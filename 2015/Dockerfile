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
ENV TEXLIVE_VERSION 2015
ENV TEXDIR /usr/local/texlive/$TEXLIVE_VERSION
ENV TEXMFCONFIG /data/.texlive$TEXLIVE_VERSION/texmf-config
ENV TEXMFHOME /data/texmf
ENV TEXMFLOCAL /usr/local/texlive/texmf-local
ENV TEXMFSYSCONFIG /usr/local/texlive/$TEXLIVE_VERSION/texmf-config
ENV TEXMFSYSVAR /usr/local/texlive/$TEXLIVE_VERSION/texmf-var
ENV TEXMFVAR /data/.texlive$TEXLIVE_VERSION/texmf-var

RUN wget ftp://tug.org/historic/systems/texlive/$TEXLIVE_VERSION/tlnet-final/install-tl-unx.tar.gz \
  && tar xzvf install-tl-unx.tar.gz \
  && ./install-tl-*/install-tl -profile /texlive.profile \
  -repository ftp://tug.org/historic/systems/texlive/$TEXLIVE_VERSION/tlnet-final \
  && rm -rf install-tl-*

VOLUME ["/data"]
