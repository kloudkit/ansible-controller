ARG tag=12-slim

################################## Temp Layer ##################################

FROM debian:${tag} AS temp

RUN mkdir -p /etc/apt/keyrings

### Install helper requirements
RUN apt-get update \
  && apt-get satisfy -y --no-install-recommends \
    "ca-certificates (>=20230311)" \
    "curl (>=7.88)" \
    "gnupg (>=2.2)" \
    "unzip (>=6.0)" \
  && rm -rf /var/lib/apt/lists/*

### Add non-standard repository keys
RUN --mount=src=src,dst=/build \
  /build/add-gpg-keyrings.sh /build/extra.gpg.txt \
  && chmod a+r /etc/apt/keyrings/*.gpg

################################## Base Layer ##################################

FROM debian:${tag} AS base
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV LANG=en_US.UTF-8

COPY src/rootfs /
COPY --from=temp /etc/apt/keyrings /etc/apt/keyrings

### Add application user
RUN adduser \
  --disabled-password \
  --gecos '' \
  --uid 1000 \
  kloud

### Install packages
RUN --mount=src=src,dst=/build \
  apt-get update \
  && apt-get satisfy -y --no-install-recommends \
    "ca-certificates (>=20230311)" \
  && apt-get update \
  && apt-get satisfy -y --no-install-recommends $(cat /build/packages.apt) \
  && rm -rf \
    /var/lib/apt/lists/* \
    /usr/lib/python3.11/EXTERNALLY-MANAGED \
  && locale-gen \
  && ln -fs "$(which python3)" /usr/bin/python

############################### Dependency Layer ###############################

FROM temp AS deps
WORKDIR /usr/local/bin
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG TARGETARCH

# renovate: source=github-releases dep=google/go-containerregistry
ARG crane_version=0.20.3

RUN case ${TARGETARCH} in "arm64") file=arm64 ;; "amd64") file=x86_64 ;; esac \
  && curl -fsSL "https://github.com/google/go-containerregistry/releases/download/v${crane_version}/go-containerregistry_Linux_${file}.tar.gz" \
    | tar -xzf - \
  && curl -fsSL "https://mirror.openshift.com/pub/openshift-v4/${file}/clients/ocp/4.17.5/openshift-client-linux.tar.gz" \
    | tar -xzf - -C /tmp \
  && cp /tmp/oc .

RUN chown -R root:root /usr/local/bin \
  && chmod -R 755 /usr/local/bin

############################### Application layer ##############################

FROM base
USER kloud
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /workspace

ENV USER=kloud
ENV PATH=${PATH}:/home/kloud/.local/bin

### Install user packages & extensions
RUN --mount=src=src,dst=/build \
  helm plugin install https://github.com/databus23/helm-diff \
  && pip install --no-cache-dir -r /build/requirements.txt \
  && pip cache purge \
  && ansible-galaxy install -r /build/requirements.yaml \
  && rm -rf \
    /home/kloud/.ansible/galaxy_cache \
    /home/kloud/.cache/helm

ENTRYPOINT ["ansible-playbook"]
