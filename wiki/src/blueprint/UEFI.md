[[!tag archived]]

We want at least basic UEFI boot including Mac.

* [[Design documentation|contribute/design/UEFI]]
* Ticket: [[!tails_ticket 5739]]
* Branch: [[!tails_gitweb_branch feature/uefi]]

[[!toc levels=2]]

<a id="testing-results"></a>

Testing results
===============

* [[blueprint/UEFI/syslinux]]
* [[blueprint/UEFI/GRUB]]

<a id="future-work"></a>

Ideas for future work
=====================

Other ideas
-----------

Most of the possible candidate goals that were
[[rejected|contribute/design/UEFI#non-goals]] for this initial iteration are not
critical. Pursuing these would require substantial effort, that is
better put into other Tails improvements. Therefore, they have not
made their way into our [[!tails_roadmap]]. Some have low-priority
tickets on [[!tails_gitlab desc="GitLab"]], meaning that patches are
welcome, but we do not feel committed, as a project, to make
it happen.

On the other hand, it appears that adding support for [[blueprint/UEFI_Secure_boot]] will be necessary at some point. More and more
off-the-shelf PC hardware is shipped with this functionality enabled.
Also, having to constantly disable and re-enable Secure boot in the
firmware configuration is not the best dual-boot user experience we
can provide (in case the other, non-Tails operating system only starts
with Secure boot enabled).

To end with, another task that we would be very happy to tackle would
be to upstream our work and make it available to all Debian Live users
and downstreams. However, as explained on [[!tails_ticket 5691]] and
<https://lists.debian.org/debian-live/2013/11/msg00017.html>:

1. we are still using an old version of live-build;
1. the upgrade process requires a lot of work;
1. we have very little incentive to upgrade;
1. even if we upgraded to the current production-ready version of
   live-build (namely: 3.x), and implemented our changes in
   `scripts/build/binary_syslinux`, then we could not easily
   forward-port them from live-build 3.x to 4.x, nor backport them
   from live-build 4.x to 3.x;
1. our past experience has shown that using in production the latest
   versions of live-*, that have not stabilized yet, simply requires
   way too much ongoing bugfixing and adapting effort for our taste
   and limited resources; so that's not an option
   either, unfortunately.

Sadly, it seems that in the current situation, the only realistic
option available to us right now is to go on using custom hooks and
configuration. The best we can do to be team players is to share our
experience and conclusions, as well as our custom scripts and
configuration. This is what we did in this document, and we hope it is
useful for many.

Resources
=========

* [The bootstrap process on EFI systems](https://lwn.net/Articles/632528/) on LWN
* lernstick Grub configuration, implemented as a live-build binary
  hook, that's meant to be nice with an existing syslinux
  configuration managed by live-build:
  <https://github.com/imedias/lernstickAdvanced.git> (oh, and they use
  the [xmlboot](https://github.com/imedias/xmlboot) gfxboot script and
  many crazy Grub configuration scripts)
* [hellais' TAILS-OSX scripts](https://github.com/hellais/TAILS-OSX)
  and the [list of
  hardware](https://github.com/hellais/TAILS-OSX/blob/master/tested-on.md)
  it was tested on
* [Mac Linux USB Loader](http://sevenbits.github.io/Mac-Linux-USB-Loader/)
  Doesn't work with Tails at the moment, but that's a frequent request
  to upstream. Upstream is working on fixing this. That would allow
  starting Tails on Mac UEFI.
* Steve McIntyre's EFI installation progress:
  - [[!debpkg debian-cd]] 3.1.11 has x86 EFI support, see the
    `debian/changelog` for details
  - [fourth](http://blog.einval.com/2012/09/03#Debian_EFI_4) (2012-09-03)
  - [third](http://blog.einval.com/2012/08/24#Debian_EFI_3)
  - [second](http://blog.einval.com/2012/08/22#Debian_EFI_2) (2012-08-22)
  - [first](http://blog.einval.com/2012/08/12#Debian_EFI) (2012-08-12)
* <https://lists.debian.org/debian-devel/2012/01/msg00168.html>
* [Debian: switch to UEFI boot](http://tanguy.ortolo.eu/blog/article51/debian-efi)
* [[!debbug 658352]] about adding UEFI support to Debian CDs
* Liberte Linux supports UEFI (with GRUB, and syslinux for BIOS boot)
* the [SprezzOS](http://www.sprezzatech.com/sprezzos.html)
  Debian derivative is [working on this](https://github.com/dankamongmen/SprezzOS/wiki/Installer) too:
  - [bug 11](https://www.sprezzatech.com/bugs/show_bug.cgi?id=11)
  - [bug 104](https://www.sprezzatech.com/bugs/show_bug.cgi?id=104)
* rEFIt developer, Rod Smith, may be willing to help.
* ArchLinux' page about
  [UEFI Bootloaders](https://wiki.archlinux.org/index.php/UEFI_Bootloaders)
* syslinux 6 (released in June 2013) has UEFI support. Debian Live's
  UEFI support will be based on it.
  - Early users [discussion and
    hints](http://www.marshut.com/kyxhm/question-about-syslinux-efi-alpha-version.html).
  - It seems that syslinux does not do very well with CD booting and
    UEFI: a FAT32 ElTorito image (with kernel, initrd and boot loader
    configuration) must be embedded into the ISO9660. syslinux can't
    read any other file system than the one it was booted from, so we
    have to duplicate these files. Also, this image must be smaller
    than 32MB. Indeed,
    [Knoppix](http://www.knopper.net/knoppix/index-en.html) 7.2 uses
    syslinux 6, and supports "UEFI-Boot (DVD: 32 and 64bit, CD: only
    32bit) *after installation on USB flash disk*".
* Kanotix, based on Debian Live and GRUB2, has a isohybrid setup that
  allows "multi-hybrid booting" as CD-ROM (EFI or El Torito) or as
  a hard-drive (e.g. a USB pendrive) on Intel-Macs (EFI) and PCs (EFI
  or MBR). [See
  details](https://mailman.boum.org/pipermail/tails-dev/2013-February/002587.html).
* Debian's Linux 3.2 kernel has "UEFI stub" support, which
  allows it to be started directly since the EFI boot menu.
* Running a UEFI firmware for virtual machines (after installing the
  `ovmf` package): `qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd`
* Ubuntu's Firmware Test Suite
  - [homepage](https://wiki.ubuntu.com/FirmwareTestSuite)
  - [[!debbug 748783 desc="Debian ITP"]]
  - [live version](https://wiki.ubuntu.com/HardwareEnablementTeam/Documentation/FirmwareTestSuiteLive)
  - [reference guide](https://wiki.ubuntu.com/Kernel/Reference/fwts)
* Peter Jones' [The EFI System Partition and the Default Boot
  Behavior](http://blog.uncooperative.org/blog/2014/02/06/the-efi-system-partition/):
  detailed description of how the firmware picks an ESP, and how
  Fedora deals with it.

More technical details:

 * <http://bazaar.launchpad.net/~libburnia-team/libisofs/scdbackup/view/head:/doc/boot_sectors.txt#L398>

OVMF
----

* The <edk2-devel@lists.sourceforge.net> mailing list is the canonical
  place for discussions on this topic.
* Ubuntu's page about OVMF: <https://wiki.ubuntu.com/UEFI/OVMF>
* <http://www.linux-kvm.org/page/OVMF>
* Fedora's [Testing secureboot with KVM](https://fedoraproject.org/wiki/Testing_secureboot_with_KVM)

### Getting OVMF

The [[!debpts ed2k]] source package (from which [[!debpkg ovmf]] is
built) is a bit outdated in Debian, but it will hopefully be enough
for our needs.

Else:

* Fresher OVMF than TianoCore's can be found at:
  - <http://www.linux-kvm.org/page/OVMF>
  - <http://people.canonical.com/~jamie/ovmf>
* One can also get a fresh UDK or use EDK-II svn trunk, to build their
  own OVMF:
  - <https://wiki.ubuntu.com/UEFI/EDK2>

### Usage in VM

* [[!debbug 714496]] documents how to use OVMF with libvirt. The [OVMF
  page](http://www.linux-kvm.org/page/OVMF) on the Linux KVM website
  documents this too. In short, add this line to the `<os>`
  section:

              <loader>/usr/share/ovmf/OVMF.fd</loader>

* Instructions that document `-pflash` & `-bios` options for running
  OVMF on QEMU can be found in the *OvmfPkg/README: Update information
  about running OVMF*
  [thread](http://permalink.gmane.org/gmane.comp.bios.tianocore.devel/5716).
