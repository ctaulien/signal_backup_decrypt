FROM golang:latest 

LABEL version="1.0"

RUN apt-get update
RUN apt install -y sudo protobuf-compiler cargo git openssl libssl-dev pkg-config sqlite3 libsqlite3-dev vim
RUN mkdir /app
WORKDIR /app

RUN groupadd --gid 409 ctaulien \
    && useradd --uid 1010 --gid ctaulien -m -b /home ctaulien -G ctaulien
RUN sudo -u ctaulien cargo install --features "rebuild-protobuf" signal-backup-decode 

WORKDIR /
