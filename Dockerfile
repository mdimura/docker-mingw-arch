# MingW64 + Qt5 for cross-compile builds to Windows
# Based on ArchLinux image

# `pacman -Scc --noconfirm` responds 'N' by default to removing the cache, hence
# the echo mechanism.

FROM base/archlinux:latest
MAINTAINER Mykola Dimura <mykola.dimura@gmail.com>

# Select a mirror
RUN cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup \
    && rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

# Update base system
RUN    pacman -Sy --noconfirm --noprogressbar archlinux-keyring \
    && pacman-key --populate \
    && pacman -Su --noconfirm --noprogressbar pacman \
    && pacman-db-upgrade \
    && pacman -Su --noconfirm --noprogressbar ca-certificates \
    && trust extract-compat \
    && pacman -Syyu --noconfirm --noprogressbar \
    && (echo -e "y\ny\n" | pacman -Scc)

# Add mingw-repo
RUN    echo "[ownstuff]" >> /etc/pacman.conf \
    && echo "SigLevel = Optional TrustAll" >> /etc/pacman.conf \
    && echo "Server = https://martchus.no-ip.biz/repo/arch/ownstuff/os/\$arch" >> /etc/pacman.conf \
    && pacman -Sy

# Add packages to the base system
RUN pacman -S --noconfirm --noprogressbar \
        imagemagick make git binutils \
        patch base-devel python2 wget \
        expac yajl nano \
    && (echo -e "y\ny\n" | pacman -Scc)

# Install MingW packages (from ownstuff)
RUN pacman -S --noconfirm --noprogressbar \
        mingw-w64-binutils \
        mingw-w64-crt \
        mingw-w64-gcc \
        mingw-w64-headers \
        mingw-w64-winpthreads \
        mingw-w64-bzip2 \
        mingw-w64-cmake \
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
        mingw-w64-qt5-webkit \
        mingw-w64-qt5-websockets \
        mingw-w64-qt5-winextras \
        mingw-w64-readline \
        mingw-w64-sdl2 \
        mingw-w64-sqlite \
        mingw-w64-termcap \
        mingw-w64-tools \
        mingw-w64-zlib \
    && (echo -e "y\ny\n" | pacman -Scc)

# Create devel user...
RUN useradd -m -d /home/devel -u 1000 -U -G users,tty -s /bin/bash devel

# Install pacaur
RUN echo 'devel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER devel
RUN BUILDDIR=/home/tmp-build; \
        sudo mkdir "${BUILDDIR}"; \
        sudo chown devel.users "${BUILDDIR}"; \
        chmod 777 "${BUILDDIR}"; \
        cd "${BUILDDIR}"; \
        gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53; \
        curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower; \
        export PATH=$PATH:/usr/bin/core_perl; \
        makepkg -si --noconfirm; \
        rm PKGBUILD; \
        curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur; \
        makepkg -si --noconfirm; \
        sudo rm -rf "${BUILDDIR}"

# Install AUR packages
RUN export EDITOR=echo; export MAKEFLAGS="-j$(nproc)"; \
    pacaur -S --noconfirm --noprogressbar --noedit --silent --needed \
        mingw-w64-qt5-serialport \
        mingw-w64-configure \
        mingw-w64-jemalloc \
        mingw-w64-boost \
        mingw-w64-eigen \
        mingw-w64-python-bin \
        mingw-w64-readerwriterqueue-git \
        mingw-w64-libcuckoo-git \
        mingw-w64-async++-git \
        mingw-w64-spdlog-git
#        mingw-w64-pteros-git

# Cleanup
USER root
RUN sed -i '/devel ALL/d' /etc/sudoers; \
    paccache -r -k0; \
    pacaur -Scc; \
    rm -rf /usr/share/man/*; \
    rm -rf /tmp/*; \
    rm -rf /var/tmp/*

USER devel
ENV HOME=/home/devel
WORKDIR /home/devel

# ... but don't use it on the next image builds
ONBUILD USER root
ONBUILD WORKDIR /
