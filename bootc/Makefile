IMAGE := bootc-test

# The name of the update file.
UPDATE := ${IMAGE}-$(shell date +%s).oci

# The SSH port to use.
PORT := 2222

build:
	podman build -t ${IMAGE} -f Containerfile .

container:
	podman run --interactive --tty --rm ${IMAGE} /usr/bin/bash

image: build
	mkdir -p build/
	sudo podman build -t ${IMAGE} -f Containerfile .
	sudo podman run \
		--rm \
		-it \
		--privileged \
		--security-opt label=type:unconfined_t \
		-v ./config.toml:/config.toml:ro \
		-v ./build:/output \
		-v /var/lib/containers/storage:/var/lib/containers/storage \
		quay.io/centos-bootc/bootc-image-builder:latest \
		--type raw \
		--use-librepo=True \
		--rootfs ext4 \
		localhost/${IMAGE}
	sudo chown -R ${USER}: build

vm:
	qemu-system-x86_64 \
		-M accel=kvm \
		-cpu host \
		-smp 2 \
		-m 4096 \
		-bios /usr/share/OVMF/OVMF_CODE.fd \
		-net user,hostfwd=tcp::${PORT}-:22 \
		-net nic \
		-nographic \
		-snapshot build/image/disk.raw

ssh:
	ssh -o "StrictHostKeyChecking no" \
		-o "UserKnownHostsFile=/dev/null" \
		-p ${PORT} \
		admin@localhost

update:
	mkdir -p build/
	sudo podman image save ${IMAGE} --output build/${UPDATE} --format oci-archive
	scp -o "StrictHostKeyChecking no" \
		-o "UserKnownHostsFile=/dev/null" \
		-P ${PORT} \
		build/${UPDATE} \
		admin@localhost:/tmp/${UPDATE}
	ssh -o "StrictHostKeyChecking no" \
		-o "UserKnownHostsFile=/dev/null" \
		-p ${PORT} \
		admin@localhost \
		"sudo bootc switch --transport oci-archive --apply /tmp/${UPDATE}"

clean:
	rm -rf build

.PHONY: build container image vm update clean ssh
