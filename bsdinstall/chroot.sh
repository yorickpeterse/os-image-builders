#!/usr/bin/env sh

export IGNORE_OSVERSION=yes
export ASSUME_ALWAYS_YES=yes

pkg bootstrap -r FreeBSD
pkg update -f
pkg install fastfetch htop neovim

# Clean up temporary files
pkg clean -a && pkg delete -f pkg && rm -rf /var/db/pkg/repos
