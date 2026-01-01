# Building a Linux image using mkosi

This directory contains files for building a Fedora 43 VM image using
[mkosi](https://mkosi.systemd.io/).

## Requirements

- mkosi
- A Fedora 43 host (I think?)

## Building

Run `make` to build the image, them `make vm` to start the VM using qemu. The
username and password is `root`.

## Updating

I didn't implement this because I gave up.

## Random notes

- Partitioning is done using systemd-repart, but it requires you to set up a
  partitioning configuration both at build time and runtime (for the first
  boot). This is confusing because it's not always clear what goes where (e.g.
  should `Label` be used in both?)
- While you _can_ add users using a build hook, due to the mkosi sandbox' inner
  workings you can't change permissions, instead you're effectively forced to
  use systemd-sysuers to create users and systemd-tmpfiles to correct
  permissions (e.g. for an SSH key)
- Partitioning seems to require copying data from the host, at least for the
  root partition. Without this you won't be able to boot the VM
- `mkosi build` is quite noisy
- Incremental builds are stupid and are only flushed if you change the list of
  packages, making them effectively useless
- In general it seems bare metal deployments are more of an afterthought than an
  actual goal/desire
- The manual pages are pretty good, though you often have to jump between
  different ones (e.g. `man tmpfiles.d` and `man repart.d`), and the manual page
  format isn't great
- There aren't really any end-to-end guides, and most of what's written is
  outdated
- Updates would be done using systemd-sysupdate, but I haven't been able to look
  into this too deeply as I gave up after a wild-goose chase that spanned two
  days in trying to figure out how mkosi works
- Immutable `/` and `/etc` but with a mutable `/var` doesn't work (see
  <https://github.com/systemd/systemd/issues/31071> and
  <https://github.com/systemd/systemd/issues/39438>), and I couldn't get the
  various suggestions to work no matter what
- If you don't specify `RuntimeSize` then the image is as large as the sum of
  the partitions in `mkosi.repart`. This however will likely result in
  systemd-repart failing to resize partitions on boot because of there not being
  enough disk space (this was part of the wild-goose chase), so I ended up
  setting it to a size a little larger than this sum size
- I have no idea how the above affects physical hardware installations
- In typical systemd fashion, there are many different locations configuration
  files may be sourced from, and the documentation sometimes suggests you to put
  them in location A while other times it suggests location B. This ends up
  being rather confusing
- The Fedora installation is _extremely_ bare-bones. On one end this is good
  (e.g. no Fedora bloat such as cockpit by default), on the other end it means
  you have to install and enable even the most basic services yourself (e.g.
  systemd-networkd). This isn't bad and all that different from e.g. FreeBSD,
  but it's something you need to keep in mind (e.g. this isn't as easy to set up
  as Fedora Server)
- In trying to get immutable `/etc` and `/` to work I ended up trying mkosi
  `main` which failed to build due to some `modprobe`/`modinfo` command not
  working. Not sure what's up with that, but the resulting error was utterly
  useless (it basically just said the equivalent of "failure" and that's it)
- It feels like the whole setup tries to do too much at the first boot such as
  writing `/etc/machine-id` (why is that even a thing in the first place?) and
  repartitioning disks. For disks it _can_ be useful to partition extra disks
  specific to a certain machine, but why can't I just bake all of that in the
  image if I want to have a fully deterministic boot phase?
- More specifically, if I have 200 servers to provision I don't want to have 5
  fail because systemd-repartd randomly pooped its pants, I want the equivalent
  of `dd if=IMAGE of=SERVER` and have a fully set up system
