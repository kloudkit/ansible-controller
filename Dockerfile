ARG tag=v0.0.4-trixie

################################## Temp Layer ##################################

FROM ghcr.io/kloudkit/base-image:${tag} AS temp

################################## Base Layer ##################################

FROM ghcr.io/kloudkit/base-image:${tag} AS base
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY src/rootfs /

### Install packages
RUN --mount=src=src,dst=/build \
  /usr/libexec/kloudkit/install-apt-keyring -f /build/additional.gpg.txt \
  && apt-get update \
  && apt-get satisfy -y --no-install-recommends $(cat /build/packages.apt) \
  && rm -rf \
    /var/lib/apt/lists/* \
    /usr/lib/python3.*/EXTERNALLY-MANAGED \
  && ln -fs "$(which python3)" /usr/bin/python

RUN mkdir -p /home/kloud \
  && chown -R kloud:kloud /home/kloud

############################### Dependency Layer ###############################

FROM temp AS deps
WORKDIR /usr/local/bin
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG TARGETARCH

# renovate: source=github-releases dep=google/go-containerregistry
ARG crane_version=0.20.7

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
