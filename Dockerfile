FROM ghcr.io/prulloac/base:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gnome-keyring \
        libsecret-1-0 \
        libsecret-tools \
        dbus \
    && rm -rf /var/lib/apt/lists/*
