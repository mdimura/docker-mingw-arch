# MingW64 + Qt5 (optionally) for cross-compiling to Windows
# Based on ArchLinux image
ARG DOCKER_TAG=qt

FROM archlinux/base:latest as base
MAINTAINER Mykola Dimura <mykola.dimura@gmail.com>

# Create devel user...
RUN useradd -m -d /home/devel -u 1000 -U -G users,tty -s /bin/bash devel
RUN echo 'devel ALL=(ALL) NOPASSWD: /usr/sbin/pacman, /usr/sbin/makepkg' >> /etc/sudoers;

RUN mkdir -p /workdir && chown devel.users /workdir

#Workaround for the "setrlimit(RLIMIT_CORE): Operation not permitted" error
RUN echo "Set disable_coredump false" >> /etc/sudo.conf

RUN pacman -Syyu --noconfirm --noprogressbar 

# Add packages to the base system
RUN pacman -S --noconfirm --noprogressbar \
        imagemagick make git binutils \
        patch base-devel wget \
        pacman-contrib expac nano openssh

ENV EDITOR=nano

# Install yay
USER devel
ARG BUILDDIR=/tmp/tmp-build
RUN  mkdir "${BUILDDIR}" && cd "${BUILDDIR}" && \
     git clone https://aur.archlinux.org/yay.git && \
     cd yay && makepkg -si --noconfirm --rmdeps && \
     rm -rf "${BUILDDIR}"

USER root

# Add mingw-repo
RUN    echo "[ownstuff]" >> /etc/pacman.conf \
    && echo "SigLevel = Optional TrustAll" >> /etc/pacman.conf \
    && echo "Server = https://martchus.no-ip.biz/repo/arch/ownstuff/os/\$arch" >> /etc/pacman.conf \
    && pacman -Sy 

# Install essential MingW packages (from ownstuff)
RUN pacman -S --noconfirm --noprogressbar \
        mingw-w64-binutils \
        mingw-w64-crt \
        mingw-w64-gcc \
        mingw-w64-headers \
        mingw-w64-winpthreads \
        mingw-w64-cmake \
        mingw-w64-tools \
        mingw-w64-zlib 

# Cleanup
USER root
RUN pacman -Scc --noconfirm
RUN paccache -r -k0; \
    rm -rf /usr/share/man/*; \
    rm -rf /tmp/*; \
    rm -rf /var/tmp/*;
USER devel
RUN yay -Scc

ENV HOME=/home/devel

WORKDIR /workdir
ONBUILD USER root
ONBUILD WORKDIR /


FROM base as qt

USER root
# Install Qt5 and some other MingW packages (from ownstuff)
RUN pacman -S --noconfirm --noprogressbar \        
        mingw-w64-bzip2 \
        mingw-w64-expat \
        mingw-w64-fontconfig \
        mingw-w64-freeglut \
        mingw-w64-freetype2 \
        mingw-w64-gettext \
        mingw-w64-libdbus \
        mingw-w64-libiconv \
        mingw-w64-libjpeg-turbo \
        mingw-w64-libpng \
        mingw-w64-libtiff \
        mingw-w64-libxml2 \
        mingw-w64-mariadb-connector-c \
        mingw-w64-openssl \
        mingw-w64-openjpeg \
        mingw-w64-openjpeg2 \
        mingw-w64-pcre \
        mingw-w64-pdcurses \
        mingw-w64-pkg-config \
        mingw-w64-readline \
        mingw-w64-sdl2 \
        mingw-w64-sqlite \
        mingw-w64-termcap \
        mingw-w64-qt5-base \
        mingw-w64-qt5-declarative \
        mingw-w64-qt5-graphicaleffects \
        mingw-w64-qt5-imageformats \
        mingw-w64-qt5-location \
        mingw-w64-qt5-multimedia \
        mingw-w64-qt5-quickcontrols \
        mingw-w64-qt5-script \
        mingw-w64-qt5-sensors \
        mingw-w64-qt5-svg \
        mingw-w64-qt5-tools \
        mingw-w64-qt5-translations \
        mingw-w64-qt5-websockets \
        mingw-w64-qt5-winextras

# Install AUR packages
USER devel
RUN yay -S --noconfirm --noprogressbar --needed \
        mingw-w64-boost \
        mingw-w64-eigen \
        mingw-w64-qt5-quickcontrols2 \
        mingw-w64-qt5-serialport \
        mingw-w64-configure \
        mingw-w64-python-bin 

# Cleanup
USER root
RUN pacman -Scc --noconfirm
RUN paccache -r -k0; \
    rm -rf /usr/share/man/*; \
    rm -rf /tmp/*; \
    rm -rf /var/tmp/*;
USER devel
RUN yay -Scc

WORKDIR /workdir
ONBUILD USER root
ONBUILD WORKDIR /


FROM ${DOCKER_TAG} as current
USER devel
WORKDIR /workdir
ONBUILD USER root
ONBUILD WORKDIR /
