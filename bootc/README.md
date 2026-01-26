# Building a Linux image using bootc

## Requirements

- Podman

## Building

All these steps use `sudo` internally as bootc-image-builder requires root
access:

1. `make build` to build the container
1. `make image` to build the VM image
1. `make vm` to start the VM

Once the VM is started you can SSH into it as follows:

```bash
ssh -o "UserKnownHostsFile=/dev/null" admin@localhost -p 2222
```

## Updating

Run `make build` to build a new container image, then `make update` to upload
the image to the VM and apply it. This approach isn't ideal because you end up
uploading the entire image instead of only the changed layers, but it's easier
for this particular case as it removes the need for a centralized image
registry.


## Random notes

- https://github.com/osbuild/bootc-image-builder is wonky and requires root
- https://github.com/bootc-dev/bcvk is supposed to address that, but some of it
  commands are rather buggy (e.g. `bcvk libvirt run` failes with vague errors)
- Since you have to use systemd-sysusers and systemd-tmpfiles to set up
  users and fix permissions, the `Containerfile` ends up doing not much more
  than installing packages and copying files into the right place
- `bcvk to-disk --format qcow2 bootc-test disk.qcow2` fails because it tries to
  remove `/var/lib/containers/storage/overlay` in the VM, but the device is
  still busy
- The bcvk codebase has a whole bunch of `// Phase 1: ...`, `// Phase 2: ...`
  comments. I've seen LLMs also do that, so I'm a little suspicious as to the
  origin of the code. LLM vomit would certainly explain the buggy nature
- Yup, bootc/bcvk uses LLM generated code per [this
  commit](https://github.com/bootc-dev/bootc/commit/d5dd1af815e50c4e2d6c96cb0eefa682557ce854).
  Yikes
- `bcvk libvirt run` also doesn't work, brilliant
- Building using the image builder takes about 1.8 minutes for the image. Add to
  that the container build time and it all ends up taking quite a while compared
  to mkosi
- mkosi VMs start up much faster, probably due to using sytemd-boot instead of
  GRUB
- I don't like the Red Hat (adjacent) stack where to solve problem X you need
  tools A, B, C, D, some of which overlap to some degree and some of which are
  experimental or deprecated
- bootc documentation is sorely lacking, and the Fedora documentation is no
  better. At times you'll find links to GitHub projects that moved to GitLab,
  but are then archived or just not maintained by the looks of it
- Some of the bootc (adjacent) projects exist on GitHub, others on GitLab. Make
  up your mind already!
- When using `bootc switch` apparently the filename matters. If you use the same
  file name (e.g. `update.oci`) it refuses to apply the update after the first
  time, because `bootc` seems to think this means it's the same as the currently
  running system. Brilliant
- Users created using `systemd-sysusers` are only created if they don't already
  exist. This means you can't use it to change them, such as by changing their
  home directory. There's not really any other tool either, short of a custom
  `.service` file that runs a migration script of some sort
- I know sysusers aren't really meant for this, but the alternatives are worse

To upload an image to Hetzner cloud, run the following:

```bash
cat build/image/disk.raw | zstd -3 | \
    ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no" \
    root@IP_ADDRESS \
    'zstd --decompress | dd of=/dev/sda bs=1M status=progress'
ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no" \
    root@IP_ADDRESS reboot
```

Script host checking is disabled because re-imaging the server otherwise results
in SSH screaming the host changed. Of course you want to remove these `-o`
options once the server is rebooted into the new bootc installation.

You can also update an existing Fedora 43 installation like so (by running this
on the host), based on [this
article](https://fale.io/blog/2025/03/31/fedora-on-scaleway-dedibox-with-bootc):

```bash
podman run --rm \
    -v /dev:/dev \
    -v /var/lib/containers:/var/lib/containers \
    -v /:/target \
    --privileged \
    --pid=host \
    --security-opt label=type:unconfined_t \
    ghcr.io/yorickpeterse/os-image-builders:bootc \
    bootc install to-existing-root \
    --root-ssh-authorized-keys /target/root/.ssh/authorized_keys \
    --cleanup \
    --acknowledge-destructive
```

After a reboot you'll have a new bootc installation, though the bootloader
update service seems to fail and after another reboot the cleanup service fails.
There's probably something simple I overlooked, but I'd probably just go with
imaging from scratch.
