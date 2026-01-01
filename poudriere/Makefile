# The name of the image.
NAME := custom

# The name of the jail to use for building the image.
JAIL := ${NAME}-image

# The hostname to use for the machine set up using the image.
HOST := freebsd-custom

# The ports tree to use.
TREE := latest

# The version of FreeBSD to use.
VERSION := 15.0-RELEASE

# The FreeBSD kernel to use.
KERNEL := GENERIC

# The size of the disk image.
SIZE := 10g

# The size of the swap partition.
SWAP := 1g

image:
	mkdir -p build
	poudriere image \
		-j ${JAIL} \
		-p ${TREE} \
		-n ${NAME} \
		-h ${HOST} \
		-s ${SIZE} \
		-w ${SWAP} \
		-f ./packages.txt \
		-t zfs+gpt \
		-A hooks/post-build.sh \
		-c overlay \
		-o build

ports:
	poudriere ports -c -p latest -B main

jail:
	poudriere jail -c -j ${JAIL} -K ${KERNEL} -m ftp -v ${VERSION}

snapshot:
	mkdir -p build
	poudriere image \
		-j ${JAIL} \
		-p ${TREE} \
		-n update \
		-h ${HOST} \
		-s ${SIZE} \
		-w ${SWAP} \
		-f ./packages.txt \
		-t zfs+send+be \
		-A hooks/post-build.sh \
		-c overlay \
		-o build
clean:
	rm -rf build
	poudriere jail -d -j ${JAIL} -y

.PHONY: image ports snapshot jail clean
