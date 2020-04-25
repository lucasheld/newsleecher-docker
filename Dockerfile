FROM jlesage/baseimage-gui:ubuntu-18.04

# current final: https://www.newsleecher.com/nl_setup.exe
# current beta: https://newsleecher.com/nl_setup_beta.exe
# old releases: https://www.newsleecher.com/releases/
ARG NEWSLEECHER_URL="https://www.newsleecher.com/nl_setup.exe"

ENV \
    DEBIAN_FRONTEND=noninteractive \
    WINEPREFIX=/wine \
    WINEARCH=win32 \
    APP_NAME="NewsLeecher"

WORKDIR /tmp

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

RUN set -x \
    # generate and install favicon
    && APP_ICON_URL=https://www.newsleecher.com/apple-touch-icon.png \
    && install_app_icon.sh "$APP_ICON_URL" \
    # enable window decor to allow newsleecher restart
    && sed-patch 's|<decor>no</decor>|<decor>yes</decor>|' /etc/xdg/openbox/rc.xml

VOLUME [ "/config" ]
VOLUME [ "/storage" ]
VOLUME [ "/wine/drive_c/users/app/Application Data/NewsLeecher" ]

COPY rootfs/ /

LABEL \
    org.label-schema.name="newsleecher" \
    org.label-schema.description="Docker container for NewsLeecher" \
    org.label-schema.vcs-url="https://github.com/lucasheld/newsleecher-docker" \
    org.label-schema.schema-version="1.0"
