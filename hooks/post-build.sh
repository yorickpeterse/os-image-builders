#!/usr/bin/env sh

run() {
    chroot "${WRKDIR}/world" "$@"
}

# Create a root-ish user. Usually this would be used for e.g. applying updates
# or deploying a new application. We don't create a home directory because the
# mtree file takes care of that, and this way we don't end up with the contents
# of /usr/share/skel in the home directory.
run pw useradd -u 1000 -h - -G wheel -n admin

# The patch from https://github.com/freebsd/poudriere/pull/1200, which isn't
# released yet.
if [ -f "${EXTRADIR}/.mtree" ]
then
	run mtree -eiU <"${EXTRADIR}/.mtree" >/dev/null
	run rm /.mtree
fi
