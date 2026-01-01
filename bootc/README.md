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

In theory this is done using the `bootc` command, but this requires either an
OCI image registry or a local upload of the image. I haven't bothered with this
yet.

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
