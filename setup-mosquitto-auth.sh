#!/bin/bash
# Builds mosquitto and mosquitto-auth-plugin, based on:
# http://www.kirang.in/2015/05/23/setting-up-acl-in-mosquitto-using-postgres
# http://my-classes.com/2015/02/05/acl-mosquitto-mqtt-broker-auth-plugin/
# Requires configuration in mosquitto.conf

VERSION=1.4.5
CWD=`pwd`

# Runs sed and only overwrites file on success
function safe_sed {
	echo $2
	sed -e "$2" $1 > $1.tmp && mv $1.tmp $1
}

# Abort in case of errors
set -e

# Install dependencies
sudo apt-get install libc-ares-dev libcurl4-openssl-dev uuid-dev postgresql libpq-dev git

# Download mosquitto source
if [ ! -d "mosquitto-$VERSION" ]; then
	wget http://mosquitto.org/files/source/mosquitto-$VERSION.tar.gz
	tar -xf mosquitto-$VERSION.tar.gz
fi

# Build mosquitto
#cd mosquitto-$VERSION && make -j4 mosquitto && cd ..

# Clone auth plugin
if [ ! -d "mosquitto-auth-plug" ]; then
	git clone git@github.com:jpmens/mosquitto-auth-plug.git
fi
cd mosquitto-auth-plug
#git pull origin master
cp config.mk.in config.mk

# Enable required connectors
safe_sed config.mk 's|BACKEND_POSTGRES ?= no|BACKEND_POSTGRES ?= yes|g'

# Set mosquitto source location
safe_sed config.mk 's|MOSQUITTO_SRC =|MOSQUITTO_SRC = $CWD/mosquitto-$VERSION|g'

# Build auth plugin
make

# Copy into mosquitto install location
sudo cp auth-plug.so /etc/mosquitto/

# Return to parent dir
cd ..
