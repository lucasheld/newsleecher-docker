FROM jlesage/baseimage-gui:ubuntu-18.04

ENV DEBIAN_FRONTEND=noninteractive \
    WINEPREFIX=/wine \
    WINEARCH=win32 \
    APP_NAME="NewsLeecher" \
    NEWSLEECHER_URL="https://newsleecher.com/nl_setup_beta.exe"

VOLUME [ "/config" ]
VOLUME [ "/wine/drive_c/users/app/Application Data/NewsLeecher" ]

RUN set -x \
    # upgrade system
    && apt-get update \
    && apt-get upgrade -y \
    # install wine
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -yq wine32 winbind \
    # install winetricks
    && apt-get install -yq wget cabextract \
    && wget -q https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x winetricks \
    && mv winetricks /usr/local/bin \
    # download newsleecher
    && wget -qO /tmp/newsleecher.exe $NEWSLEECHER_URL \
    # start x server
    && (/usr/bin/Xvfb :0 &) \
    && while ! xdpyinfo -display :0 > /dev/null 2>&1; do sleep 1; done \
    # install newsleecher
    && DISPLAY=:0 wine /tmp/newsleecher.exe /SILENT \
    # stop x server
    && while ps | grep -v grep | grep -qw wineserver; do sleep 1; done \
    && kill $(cat /tmp/.X0-lock) \
    && while ps | grep -v grep | grep -qw Xvfb; do sleep 1; done \
    # modify wine to run newsleecher
    && winetricks winxp \
    && winetricks dxvk \
    # cleanup
    && apt-get remove -yq wget cabextract \
    && apt-get -q clean \
    && rm -fr /var/lib/apt/lists/* /var/log/dpkg.log /var/log/alternatives.log /var/log/apt/* \
    && rm -fr /tmp/*

COPY rootfs/ /
