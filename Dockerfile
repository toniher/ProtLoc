FROM biocorecrg/debian-perlbrew:stretch

# File Author / Maintainer
MAINTAINER Toni Hermoso Pulido <toni.hermoso@crg.eu>

RUN set -x ; apt-get update && apt-get -y upgrade

# Place /scripts
RUN mkdir -p /scripts

# Perl packages
RUN cpanm Bio::SearchIO Math::MatrixReal
RUN cpanm JSON Mojolicious::Lite

COPY *pl /scripts/
COPY *pm /scripts/
COPY avg /scripts/avg
COPY var /scripts/var
COPY data /scripts/data

# Clean cache
RUN apt-get clean
RUN set -x; rm -rf /var/lib/apt/lists/*

RUN chmod -R a+rx /scripts/*pl

RUN ln -s /scripts/protloc.pl /usr/local/bin/protloc.pl
RUN ln -s /scripts/protloc.pl /usr/local/bin/protloc

ENV PERL5LIB $PERL5LIB:/scripts

# Webserver
EXPOSE 3000

ENTRYPOINT ["morbo", "/scripts/index.pl"]
