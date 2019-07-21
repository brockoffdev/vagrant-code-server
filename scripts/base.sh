#!/usr/bin/env bash

# Update
echo ">>> Upgrade distro"
sudo apt-get -qq update && sudo apt-get -f -y -qq upgrade && sudo apt-get -f -y -qq dist-upgrade

echo ">>> Setting Timezone $3"
sudo ln -sf /usr/share/zoneinfo/$3 /etc/localtime

if [[ $(locale | grep LANGUAGE | cut -d= -f2 | cut -d_ -f1) -ne "en" ]]; then
    echo ">>> Setting Locale to en_US.UTF-8"
    sudo apt-get install -qq language-pack-en
    sudo locale-gen en_US
    sudo update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
fi

echo ">>> Installing Base Packages"

if [[ -z $1 ]]; then
    github_url="https://raw.githubusercontent.com/olegshulyakov/vagrant-code-server/master"
else
    github_url="$1"
fi

# Install base packages
# -qq implies -y --force-yes
sudo apt-get install -qq vim \
    curl \
    wget \
    htop \
    zip \
    unzip \
    git \
    git-core \
    ack-grep \
    software-properties-common \
    virtualbox-guest-dkms \
    build-essential \
    cachefilesd \
    openssl \
    net-tools \
    locales

# Install self-signed SSL
SSL_DIR="/etc/ssl/xip.io"
DOMAIN="*.xip.io"
PASSPHRASE="vaprobash"

SUBJ="
C=US
ST=Connecticut
O=Vaprobash
localityName=New Haven
commonName=$DOMAIN
organizationalUnitName=
emailAddress=
"
if [[ ! -d "/home/vagrant/code-server" ]]; then
    echo ">>> Installing *.xip.io self-signed SSL"

    sudo mkdir -p "$SSL_DIR"

    sudo openssl genrsa -out "$SSL_DIR/xip.io.key" 1024
    sudo openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$SSL_DIR/xip.io.key" -out "$SSL_DIR/xip.io.csr" -passin pass:$PASSPHRASE
    sudo openssl x509 -req -days 365 -in "$SSL_DIR/xip.io.csr" -signkey "$SSL_DIR/xip.io.key" -out "$SSL_DIR/xip.io.crt"

else
    echo ">>> Self-signed SSL is already installed"
fi

# Setting up Swap

# Disable case sensitivity
shopt -s nocasematch

if [[ ! -z $2 && ! $2 =~ false && $2 =~ ^[0-9]*$ ]]; then

    echo ">>> Setting up Swap ($2 MB)"

    # Create the Swap file
    fallocate -l $2M /swapfile

    # Set the correct Swap permissions
    chmod 600 /swapfile

    # Setup Swap space
    mkswap /swapfile

    # Enable Swap space
    swapon /swapfile

    # Make the Swap file permanent
    echo "/swapfile   none    swap    sw    0   0" | tee -a /etc/fstab

    # Add some swap settings:
    # vm.swappiness=10: Means that there wont be a Swap file until memory hits 90% useage
    # vm.vfs_cache_pressure=50: read http://rudd-o.com/linux-and-free-software/tales-from-responsivenessland-why-linux-feels-slow-and-how-to-fix-that
    printf "vm.swappiness=10\nvm.vfs_cache_pressure=50" | tee -a /etc/sysctl.conf && sysctl -p

fi

# Enable case sensitivity
shopt -u nocasematch

# Enable cachefilesd
if [[ ! -f "/etc/default/cachefilesd" ]]; then
    sudo echo "RUN=yes" >/etc/default/cachefilesd
fi
