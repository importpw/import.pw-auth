FROM ubuntu:18.04 AS base
ARG REGISTRY_AUTH_USERNAME
ARG REGISTRY_AUTH_PASSWORD
SHELL ["/bin/bash", "-c"]
WORKDIR /usr/src
RUN apt-get update && apt-get install -y apache2-utils
COPY config.yml config.template.yml
RUN cat config.template.yml | \
  sed "s/REGISTRY_AUTH_USERNAME/$REGISTRY_AUTH_USERNAME/g" | \
  sed "s/REGISTRY_AUTH_PASSWORD/$(htpasswd -B -i -n _ <<< "$REGISTRY_AUTH_PASSWORD" | cut -c 3-)/g" \
  > config.yml

FROM cesanta/docker_auth:1
ARG REGISTRY_AUTH_CERT
ARG REGISTRY_AUTH_KEY
RUN echo "$REGISTRY_AUTH_CERT" | base64 -d > /etc/auth-cert.pem
RUN echo "$REGISTRY_AUTH_KEY" | base64 -d > /etc/auth-key.pem
COPY --from=base /usr/src/config.yml /config/auth_config.yml
