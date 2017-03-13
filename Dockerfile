# MingW64 + Qt5 for cross-compile builds to Windows
# Based on ArchLinux image

# `pacman -Scc --noconfirm` responds 'N' by default to removing the cache, hence
# the echo mechanism.

FROM base/archlinux:latest
MAINTAINER Mykola Dimura <mykola.dimura@gmail.com>

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

# Add archlinuxfr repo (yaourt)
RUN    echo "[archlinuxfr]" >> /etc/pacman.conf \
    && echo "SigLevel = Never" >> /etc/pacman.conf \
    && echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf \
    && pacman -Sy

# Add some useful packages to the base system
RUN pacman -S --noconfirm --noprogressbar \
        imagemagick make git binutils \
        patch base-devel python2 wget \
        expac yajl \
    && (echo -e "y\ny\n" | pacman -Scc)

# Install MingW packages
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
        mingw-w64-qt5-quick1 \
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

# Install pacaur packages
RUN BUILDDIR=/home/tmp-build; \
        mkdir "${BUILDDIR}"; \
        chown devel.users "${BUILDDIR}"; \
        chmod 777 "${BUILDDIR}"; \
        cd "${BUILDDIR}"; \
        export TMPDIR="${BUILDDIR}/tempdir"; \
        gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53; \
        curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower; \
        su - devel -c "cd ${BUILDDIR}; makepkg --noconfirm"; \
        pacman -U cower-*.pkg.tar.xz; \
        rm PKGBUILD; \
        curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur; \
        su - devel -c "cd ${BUILDDIR}; makepkg --noconfirm"; \
        pacman -U pacaur-*.pkg.tar.xz;

# Install AUR packages

USER devel
ENV HOME=/home/devel
WORKDIR /home/devel

# ... but don't use it on the next image builds
ONBUILD USER root
ONBUILD WORKDIR /
