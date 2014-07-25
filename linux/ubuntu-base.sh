#!/bin/bash

########################################################################
## Postinstall base script for a ubuntu box
########################################################################
function INSTALL_PKGS {
    sudo apt-get -y --ignore-missing install $*
}

function REMOVE_PKGS {
    sudo apt-get -y remove $*
}

function UPDATE {
    last_update=$(stat -c %X /var/lib/apt/lists/)
    last_repo_added=$(stat -c %Y /etc/apt/sources.list* | sort -n -r | head -1)
    now=$(date +%s)
    if [ $last_update -lt $last_repo_added ] || \
       [ $(($now-$last_update)) -gt 3600 ] ; then
           sudo apt-get -y update
    fi
}

## Allows sudo
########################################################################
SUDOER_LINE="$USER ALL=(ALL) NOPASSWD:ALL"
sudo grep "$SUDOER_LINE" /etc/sudoers.d/$USER > /dev/null 2> /dev/null
if [ $? -ne 0 ]
then
    sudo echo $SUDOER_LINE | sudo tee -a /etc/sudoers.d/$USER > /dev/null
    sudo chmod 0400 /etc/sudoers.d/$USER
fi

## Installs devs pkgs
########################################################################
UPDATE
sudo apt-get dist-upgrade

INSTALL_PKGS \
    alien \
    build-essential \
    checkinstall \
    curl \
    git \
    git-extras \
    libaio1 \
    libffi-dev \
    libjpeg-dev \
    libpcre3-dev \
    libreadline-dev \
    libsasl2-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    mercurial \
    nodejs \
    npm \
    p7zip-full \
    poppler-utils \
    python-dev \
    python-pip \
    python-setuptools \
    python-virtualenv \
    python3-dev \
    ranger \
    subversion \
    terminator \
    unixodbc-dev \
    vim \
    zlib1g-dev \
    zsh \
    ;

sudo ln -sf /usr/bin/nodejs /usr/bin/node

sudo -E npm install -g \
  jshint \
  jsctags \
  ;

## Misc
########################################################################
## Fix locale
INSTALL_PKGS --reinstall locales \
   && sudo localedef -v -c -i pt_BR -f UTF-8 pt_BR.UTF-8 \
   && sudo dpkg-reconfigure locales \
   ;

## Create buildout cache
BUILDOUT_DIR=/var/cache/buildout
sudo mkdir -p $BUILDOUT_DIR/{eggs,dlcache}
sudo -E chown -R root.sudo $BUILDOUT_DIR
sudo -E chmod a+rws -R $BUILDOUT_DIR

## Create ssh key
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    mkdir -p ~/.ssh
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -q
    eval $(ssh-agent -s)
    ssh-add
fi

## Clean cache
sudo apt-get clean
