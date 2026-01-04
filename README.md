# Building OS images on FreeBSD and Linux

This repository contains a set of experiments in building immutable (ish) OS
images for FreeBSD and Linux, using the following tools:

- [Poudriere](https://github.com/freebsd/poudriere) (FreeBSD)
- [bsdinstall](https://man.freebsd.org/cgi/man.cgi?query=bsdinstall&manpath=FreeBSD+15.0-RELEASE+and+Ports) (FreeBSD)
- [mkosi](https://mkosi.systemd.io/) (Linux)
- [bootc](https://bootc-dev.github.io/bootc/intro.html) (Linux)

Each experiment resides in its own directory (e.g. `poudriere/` or `mkosi/`), so
take a look at those for more details.

## License

The code in this repository is licensed under the
[Unlicense](https://unlicense.org/). A copy of this license can be found in the
file "LICENSE".
