#!/usr/bin/env sh

export BSDINSTALL_DISTDIR="${CACHE}"
export BSDINSTALL_CHROOT="${CHROOT}"
export BSDINSTALL_LOG="/dev/null"
export TMPDIR=/tmp

export ZFSBOOT_POOL_NAME=zroot
export ZFSBOOT_POOL_CREATE_OPTIONS="-O compression=zstd-1 -O atime=off"
export ZFSBOOT_VDEV_TYPE=stripe
export ZFSBOOT_SWAP_ENCRYPTION=1

echo 'Partitioning...'
bsdinstall scriptedpart "${PARTITIONS}" >/dev/null
bsdinstall mount

echo 'Extracting...'
bsdinstall checksum

tar -xf "${CACHE}/kernel.txz" -C "${CHROOT}" --exclude boot/efi
tar -xf "${CACHE}/base.txz" -C "${CHROOT}" --exclude boot/efi
mkdir -p "${CHROOT}/boot/efi"

echo 'Configuring...'
bsdinstall bootconfig
bsdinstall config

echo 'Configuring image contents...'
cp /etc/resolv.conf "${CHROOT}/etc/resolv.conf"
cp "${PWD}/chroot.sh" "${CHROOT}/tmp/install.sh"
chroot "${CHROOT}" sh /tmp/install.sh

echo 'Cleaning up...'
rm "${CHROOT}/tmp/install.sh"
rm "${CHROOT}/etc/resolv.conf"
bsdinstall entropy
bsdinstall umount
