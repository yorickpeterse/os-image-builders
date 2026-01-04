# Building a FreeBSD image using bsdinstall

This is a failed experiment in building an immutable disk image using
`bsdinstall` shipped with FreeBSD. Instead of using `bsdinstall script ...` it
uses the underlying commands directly. This way we can avoid the ncurses (ish)
interactive UI, which is used by certain components if you run in a TTY. It
would also give a possible end user solution more information/control over the
process, as the `bsdinstall` output is as good as useless.

While the process works in that it builds an image, I'm not able to boot past
the bootloader. Given how opaque `bsdinstall` is and how messy its source code
is (seriously, why do people keep writing large projects in Bash?) I decided to
move on.

## Requirements

- FreeBSD

## Building

Run `sudo make image` to build the image, and `sudo make clean` to clean things
up (including the temporary memory disk).

## Random notes

- `bsdinstall` is very fragile and will just crash with no useful error if you
  misconfigure it in the slightest
- That or it spits out so much debug information you have no idea what's going
  on
- `bsdinstall scriptedpart` always seems to use interactive dialogues, even if
  no confirmation is necessary. This will likely mess up CI outputs
- `bsdinstall script` can be replicated by using the underlying `bsdinstall`
  commands, provided you set all the correct environment variables or it will
  crash with no useful output
