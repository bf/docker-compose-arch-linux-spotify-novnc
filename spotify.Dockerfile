# multi-stage build file
# stages: base, development & production
## base build
FROM archlinux:base-devel AS base
ARG user=makepkg

EXPOSE 6080

ENV TERM='xterm-256color'
ENV EDITOR='vim'

# generate locale
RUN sed -ie 's/^#\(en_US\.UTF-8 UTF-8\)/\1/' /etc/locale.gen && locale-gen

# Install chaotic-aur, see https://aur.chaotic.cx
ENV CHAOTIC_AUR_MIRROR='https://de-3-mirror.chaotic.cx/'
RUN pacman-key --init && \
  pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com && \
  pacman-key --lsign-key FBA220DFC880C036 && \
  pacman -U "${CHAOTIC_AUR_MIRROR}/chaotic-aur/chaotic-keyring.pkg.tar.zst" "${CHAOTIC_AUR_MIRROR}/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst" --noconfirm && \
  echo "[chaotic-aur]" >> /etc/pacman.conf && \
  echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf

# install packages
RUN pacman -Syu --needed --noconfirm tigervnc xorg-server-xvfb git

# makepkg user and workdir
RUN useradd --system --create-home $user \
  && echo "$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
USER $user
WORKDIR /home/$user

# Install yay
RUN git clone https://aur.archlinux.org/yay.git \
  && cd yay \
  && makepkg -sri --needed --noconfirm \
  && cd \
  # Clean up
  && rm -rf .cache yay

RUN sudo chown $user:$user -R .
RUN yay -S --noconfirm novnc

USER root
WORKDIR /root

RUN pacman -Scc --noconfirm


# funny part
FROM base

# RUN echo "echo xinitrc!!!" > ~/.xinitrc && chmod +x ~/.xinitrc

COPY startup.sh /root/

RUN chmod +x ~/startup.sh

CMD ~/startup.sh 