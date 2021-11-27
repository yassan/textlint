FROM node:17-slim

# install textlint
WORKDIR /opt/textlint

COPY package.json /opt/textlint
RUN yarn install

ENV PATH=$PATH:/opt/textlint/node_modules/.bin/

# そのままだとinstallしたものをつぶすので変更
WORKDIR /work

ARG GIT_REVISION=unknown
ARG GIT_ORIGIN=unknown
ARG IMAGE_NAME=unknown
ARG VERSION=unknown

LABEL git-revision=$GIT_REVISION
LABEL git-origin=$GIT_ORIGIN
LABEL image-name=$IMAGE_NAME
LABEL Name=$IMAGE_NAME
LABEL Version=$VERSION
