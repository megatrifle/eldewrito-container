# Pull ubuntu image
FROM docker.io/ubuntu:23.04

# Set environment variables
ENV ELDEWRITO_VERSION=0.6.1 \
    DISPLAY=:1 \
    DEBIAN_FRONTEND=noninteractive

# Install dependency packages
RUN apt-get update && \
    apt-get install -y wget software-properties-common apt-transport-https cabextract xvfb winbind

# Install wine
ARG WINE_BRANCH="stable"
RUN wget -nv -O- https://dl.winehq.org/wine-builds/winehq.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - \
    && echo "deb https://dl.winehq.org/wine-builds/ubuntu/ $(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2) main" >> /etc/apt/sources.list \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --install-recommends winehq-${WINE_BRANCH} \
    && rm -rf /var/lib/apt/lists/*

# Create eldewrito user
RUN mkdir /etc/eldewrito /var/log/eldewrito /opt/eldewrito && \
    chown -R 1000:1000 /opt/eldewrito && \
    groupadd --gid 1000 eldewrito && \
    useradd --uid 1000 --gid 1000 --home-dir /opt/eldewrito eldewrito

# Set eldewrito directory
WORKDIR /opt/eldewrito

# Switch to user
USER 1000

# Download winetricks from source
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x ./winetricks

# Configure wine prefix
# WINEDLLOVERRIDES is required so wine doesn't ask any questions during setup
RUN Xvfb :1 -screen 0 320x240x24 & \
    WINEDLLOVERRIDES="mscoree,mshtml=" wineboot -u && \
    wineserver -w && \
    ./winetricks -q vcrun2012 winhttp && \
    rm winetricks && \
    rm -rf .cache/

# Switch to root
USER 0

# Cleanup unneeded packages
RUN apt-get remove -y wget software-properties-common apt-transport-https cabextract && \
    rm -rf /var/lib/apt/lists/*

# Switch to user
USER 1000

# Copy in eldewrito game files
COPY --chown=1000:1000 eldewrito-game /opt/eldewrito

# Add the 'eldewrito-server' script
ADD eldewrito-server /usr/local/bin/eldewrito-server

# Set entrypoint to 'eldewrito-server' script
ENTRYPOINT ["/usr/local/bin/eldewrito-server"]

# Expose necessary ports
EXPOSE 11774/udp 11775/tcp 11776/tcp 11777/tcp
