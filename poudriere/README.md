# Building a FreeBSD image/snapshot using Poudriere

This directory contains a brief experiment in building an immutable FreeBSD
server image that's updated using ZFS snapshots, using
[Poudriere](https://man.freebsd.org/cgi/man.cgi?poudriere).

The rationale was to see what it would take to get something similar to
[bootc](https://bootc-dev.github.io/) but using FreeBSD.

## Requirements

- FreeBSD 15 or newer
- poudriere-devel because of [this bug](https://github.com/freebsd/poudriere/issues/1238),
  fixed by [this PR](https://github.com/freebsd/poudriere/pull/1271)

## Getting started

You'll need a FreeBSD host or VM, and install poudriere-devel using
`sudo pkg install poudriere-devel`, then copy `poudriere.conf` to
`/usr/local/etc/poudriere.conf`. This bit is important because you can easily
misconfigure Poudriere and be presented with absolutely worthless error
messages.

Next you'll probably want to adjust `overlay/home/admin/.ssh/authorized_keys` to
include your public key instead of mine, otherwise you can't SSH into the
server.

Once done, run the following:

```bash
sudo make ports jail image
```

This sets up the ports tree, the jail and then builds the initial image. The
image is stored in `./build/custom.img`. To run this under virt-manager you'll
have to first convert it to the qcow2 format:

```bash
qemu-img convert -O qcow2 custom.img custom.qcow2
```

You can then import this into e.g. virt-manager and boot the image. The image
starts SSH automatically and you can log in using the `admin` user.

## Updating

Part of this experiment was about _updating_ an existing server in addition to
setting up a new server. To do so, build a _snapshot_ using:

```bash
sudo make snapshot
```

You can then upload it as follows, where `SOURCE` is the IP address of the
FreeBSD VM building the image and `TARGET` is the IP of the target VM to update:

```bash
ssh your-user@SOURCE 'cat path/to/build/update.be.zfs' | ssh admin@TARGET 'sudo zfs receive -Fuv zroot/ROOT/update'
ssh admin@TARGET 'sudo bectl activate update && sudo bectl rename default old && sudo bectl rename update default && sudo shutdown -r now'
```

This uploads the ZFS snapshot to the server and stores it under
`zroot/ROOT/update`, which `bectl` automatically detects as a boot environment.
The second command activates that snapshot and swaps the old `default` snapshot
with the new one. This way you don't have to use unique snapshots for each
update and can instead use a sort of A/B partition approach. Finally the server
is rebooted, and if all goes well your changes should be applied when it comes
back online.

## Caveats/random notes

- `/home/admin` is wiped upon applying ZFS snapshots, but changes in `/var/log`
  remain. I guess this depends on what changes the image includes?
- Poudriere's code (at least the shell scripts) are a mess
- Compression can't be configured, see
  [here](https://github.com/freebsd/poudriere/issues/794) and
  [here](https://github.com/freebsd/poudriere/issues/519). Brilliant
- Poudriere's errors suck and essentially amount to literally just "error" in
  various instances
- Poudriere apparently has a tendency to build packages from source even when
  you tell it to fetch a binary package, [this PR](https://github.com/freebsd/poudriere/pull/1148)
  from 2024 is supposed to fix that to some degree, but apparently there's no
  interest in merging it?
- For some reason `sudo make jail` takes a rather long time in my VM as the
  download speed is very slow, but not always, and only for poudriere (e.g.
  `pkg` on the host is fast enough)
- `poudriere image` in general feels more like an afterthought instead of a core
  feature, and only a few people seem to use it (BSD Router Project, Klara, and
  that's basically it)
- The manual page for `poudriere image` is not great, and like many other
  FreeBSD commands it doesn't support a `-h` or `--help` option, but at least
  you can do something like `poudriere --bullshit` to get the help output. It's
  like somebody said "FreeBSD is known for good documentation? Not on my watch!"
- I'd like for the root/immutable partition to be smaller than the whole disk so
  you can use the rest for mutable data without risk of wiping it during an
  update. From what I could find partitioning a single drive into two pools is a
  no-no in ZFS land, so I'm not sure what the best approach is. Wasting a 512
  GiB NVME on an entirely immutable ZFS pool feels like a giant waste
