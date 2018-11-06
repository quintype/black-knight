FROM quay.io/quintype/black-knight:base-ubuntu-16-rbenv-ruby-2.3.0 as BUILD1
MAINTAINER devops@quintype.com

RUN apt-get update && \
    apt-get install -y postgresql \
                       postgresql-contrib \
                       libpq-dev \
                       libsqlite3-dev \
                       nodejs \
                       npm && \
     mkdir -p /app/black-knight

VOLUME ["/app/black-knight"]
WORKDIR /app/black-knight

COPY run_in_container /app/black-knight/run_in_container
ENTRYPOINT ["/app/black-knight/run_in_container"]

