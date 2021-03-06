[[!tag archived]]

[[!toc levels=2]]

Use cases
=========

Download ISO to USB
-------------------

 1. Create partition
 2. Download ISO + extract + (feed hash function || feed GnuPG)
 3. (Verify final hash ||vVerify signature)
 4. Setup bootloader (make partition bootable if needed)

As the ISO is extracted while being downloaded, there is no need
for extra space.

Security considerations for downloads are discussed on
[[todo/incremental_upgrades]].

Existing ISO to USB
-------------------

 1. Select local ISO image
 2. (Verify using GnuPG)
 3. Create partition
 4. Extract ISO
 5. Setup bootloader (make partition bootable if needed)

Running CD to USB
-----------------

 1. Create partition
 2. Read files from CD (/live/image) + verify hash + write files
    to USB
 3. Setup bootloader (make partition bootable if needed)

Running USB to USB
------------------

 1. Create partition
 2. Copy files from USB + verify hash
 3. Setup bootloader (make partition bootable if needed)

Full upgrade
------------

Full upgrades happen between major releases, eg. 0.7 and 0.8.

Upgrades should be doable in any of the above cases. Replace "create
partition" by "remove extra files on system partition".

From inside Tails it should also provide an opt-in option to download
the full ISO without going through the Tor network.

Distribution
============

Tails installer shall be available and working on a few selected non-Tails
operating systems, such as Debian GNU/Linux, Ubuntu, Microsoft Windows
or macOS. This would allow one-step installation of Tails, instead of the
current way of doing things, that requires an intermediate step: either burning
a DVD or cat'ing a hybrid'ed ISO to a temporary USB stick.

Of course, this is on top of being available in Tails itself to support
the "clone" use case.

Existing software candidates
============================

Many existing software has been [[reviewed in the past|archive]]. The best
candidate for now is [Ubuntu's usb-creator](https://launchpad.net/usb-creator)
given the following criteria:

 1. usb-creator is already in [Ubuntu](http://packages.ubuntu.com/usb-creator)
    (obviously) and has an [open ITP for Debian](http://bugs.debian.org/576359).
    If the work is done in cooperation with upstream, this gives an easy way
    to install Tails to a quite large user base.
 2. Upstream is active and there are several features branches in Launchpad.
 3. The code already supports multiple backends (UDisks and Windows, currently)
    and multiple frontends (GTK+, KDE and Windows).
