# The URL to download FreeBSD from.
URL := https://download.freebsd.org/ftp/releases/amd64/15.0-RELEASE/

# The directory to store cached files in.
CACHE := ${PWD}/cache

# The directory to store build files in.
BUILD := ${PWD}/build

# The chroot to use for building the image.
CHROOT := ${PWD}/chroot

# The ID of the memory disk to write to. Also known as "the number of the
# beastie". Get it?
MD := 666

# The name of the disk image.
IMAGE := build/build.img

${CACHE}:
	mkdir -p ${CACHE}

${BUILD}:
	mkdir -p ${BUILD}

${CHROOT}:
	mkdir -p ${CHROOT}

${CACHE}/kernel.txz:
	fetch "${URL}/kernel.txz" -o "$@"

${CACHE}/base.txz:
	fetch "${URL}/base.txz" -o "$@"

${CACHE}/MANIFEST:
	fetch "${URL}/MANIFEST" -o "$@"

${IMAGE}:
	truncate -s 2G "$@"
	mdconfig -a -f "$@" -t vnode -u ${MD}

image: ${CACHE} ${BUILD} ${CHROOT} ${IMAGE} ${CACHE}/kernel.txz ${CACHE}/base.txz ${CACHE}/MANIFEST
	env CACHE="${CACHE}" CHROOT="${CHROOT}" MD="${MD}" sh build.sh

clean:
	mdconfig -d -u md${MD}
	rm -rf build

.PHONY: image clean
