IMAGE := bootc-test

build:
	sudo podman build -t ${IMAGE} -f Containerfile .

container:
	sudo podman run --interactive --tty --rm ${IMAGE} /usr/bin/bash

image:
	mkdir -p build/
	sudo podman run \
		--rm \
		-it \
		--privileged \
		--security-opt label=type:unconfined_t \
		-v ./config.toml:/config.toml:ro \
		-v ./build:/output \
		-v /var/lib/containers/storage:/var/lib/containers/storage \
		quay.io/centos-bootc/bootc-image-builder:latest \
		--type qcow2 \
		--use-librepo=True \
		--rootfs btrfs \
		localhost/${IMAGE}
	sudo chown -R ${USER}: build

vm:
	qemu-system-x86_64 \
		-M accel=kvm \
		-cpu host \
		-smp 2 \
		-m 4096 \
		-bios /usr/share/OVMF/OVMF_CODE.fd \
		-net user,hostfwd=tcp::2222-:22 \
		-net nic \
		-nographic \
		-snapshot build/qcow2/disk.qcow2

.PHONY: build container image vm
