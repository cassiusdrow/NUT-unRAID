#!/bin/bash
BOOT="/boot/config/plugins/nut"
DOCROOT="/usr/local/emhttp/plugins/nut"

# Add nut user and group (for legacy packages)
if [ "$( grep -ic "218" /etc/group )" -eq 0 ]; then
    groupadd -g 218 nut
fi

if [ "$( grep -ic "218" /etc/passwd )" -eq 0 ]; then
    useradd -u 218 -g nut -s /bin/false nut
fi

# Update file permissions of scripts
chmod +0755 $DOCROOT/scripts/* \
        /etc/rc.d/rc.nut \
        /etc/rc.d/rc.nutstats \
        /usr/sbin/nut-notify \
        /usr/sbin/nutstats

# copy the default
cp -n $DOCROOT/default.cfg $BOOT/nut.cfg >/dev/null 2>&1

# remove nut symlink (for legacy packages)
if [ -L /etc/nut ]; then
    rm -f /etc/nut
    mkdir /etc/nut
fi

# create nut directory
if [ ! -d /etc/nut ]; then
    mkdir /etc/nut
fi

# prepare conf backup directory on flash drive, if it does not already exist
if [ ! -d $BOOT/ups ]; then
    mkdir $BOOT/ups
fi

# copy default conf files to flash drive, if no backups exist there
cp -nr $DOCROOT/nut/* $BOOT/ups >/dev/null 2>&1

# copy conf files from flash drive to local system, for our services to use
cp -rf $BOOT/ups/* /etc/nut >/dev/null 2>&1

# set up permissions
if [ -d /etc/nut ]; then
    echo "Updating permissions for NUT..."
    chown root:nut /etc/nut
    chmod 750 /etc/nut
    chown root:nut /etc/nut/*
    chmod 640 /etc/nut/*
    chown root:nut /var/run/nut
    chmod 0770 /var/run/nut
    chown root:nut /var/state/ups
    chmod 0770 /var/state/ups
fi
