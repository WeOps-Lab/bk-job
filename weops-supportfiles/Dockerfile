FROM node:14.18 as web-builder
RUN yarn config set registry https://registry.npm.taobao.org/
RUN npm config set registry https://registry.npm.taobao.org
WORKDIR /apps
COPY . .
RUN make ui

FROM gradle:7.5.1-jdk8-focal as builder
RUN apt-get update && \
    apt-get install -y make && \
    rm -rf /var/lib/apt/lists/*
COPY --from=web-builder /apps/ /apps/
WORKDIR /apps
RUN make server
RUN make release

FROM openjdk:8u102-jre
WORKDIR /apps
COPY --from=builder /opt/release/job /apps/job
