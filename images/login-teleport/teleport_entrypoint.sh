#!/bin/bash

set -e

echo "Link users from jail"
ln -s /mnt/jail/etc/passwd /etc/passwd
ln -s /mnt/jail/etc/group /etc/group
ln -s /mnt/jail/etc/shadow /etc/shadow
ln -s /mnt/jail/etc/gshadow /etc/gshadow
chown -h 0:42 /etc/{shadow,gshadow}

echo "Link SSH \"message of the day\" scripts from jail"
ln -s /mnt/jail/etc/update-motd.d /etc/update-motd.d

echo "Link home from jail"
ln -s /mnt/jail/home /home

echo "Creating symlink to the slurm configs"
rm -rf /etc/slurm && ln -s /mnt/jail/etc/slurm /etc/slurm

echo "Link soperator home directories from jail"
mkdir -p /mnt/jail/opt/soperator-home
ln -s /mnt/jail/opt/soperator-home /opt/soperator-home

echo "Link custom SLURM plugins to PluginDir"
ALT_ARCH=$(uname -m)
mkdir -p /usr/lib/slurm
ln -sf /usr/lib/${ALT_ARCH}-linux-gnu/slurm/chroot.so /usr/lib/slurm/chroot.so
ln -sf /usr/lib/${ALT_ARCH}-linux-gnu/slurm/spanknccldebug.so /usr/lib/slurm/spanknccldebug.so
ln -sf /usr/lib/${ALT_ARCH}-linux-gnu/slurm/spank_pyxis.so /usr/lib/slurm/spank_pyxis.so

echo "Complement jail rootfs"
/opt/bin/slurm/complement_jail.sh -j /mnt/jail -u /mnt/jail.upper

echo "Waiting until munge started"
while [ ! -S "/run/munge/munge.socket.2" ]; do sleep 2; done

echo "Starting teleport"
INSECURE_FLAG=""
if [ "${TELEPORT_INSECURE}" = "true" ]; then
    INSECURE_FLAG="--insecure"
fi
exec teleport start ${INSECURE_FLAG} --config=/etc/teleport.yaml
