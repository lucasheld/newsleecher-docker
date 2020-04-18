FROM jlesage/baseimage-gui:ubuntu-18.04

ENV DEBIAN_FRONTEND=noninteractive \
    WINEPREFIX=/wine \
    WINEARCH=win32 \
    APP_NAME="NewsLeecher"

VOLUME [ "/data" ]

RUN set -x \
    # upgrade system
    && apt-get update \
    && apt-get upgrade -y \
    # install wine
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -yq wine32 winbind \
    # install winetricks
    && apt-get install -yq wget \
    && wget -q https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x winetricks \
    && mv winetricks /usr/local/bin \
    # create wine folder
    && mkdir $WINEPREFIX \
    && chown 1000:1000 $WINEPREFIX \
    && chmod 777 $WINEPREFIX

ENV NEWSLEECHER_URL="https://newsleecher.com/nl_setup_beta.exe"

COPY startapp.sh /startapp.sh
