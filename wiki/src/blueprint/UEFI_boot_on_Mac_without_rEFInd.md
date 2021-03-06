[[!tag archived]]

Ticket: [[!tails_ticket 6242]]

[[!toc levels=2]]

Status
======

At least on some Mac's, once feature/uefi is merged, Tails can boot
fine without rEFInd: one has to press Alt before powering the laptop
up, and keep it pressed until a menu appears, and then choose the
entry that's called *Boot EFI* (as every other entry) and looks like
a USB stick.

Resources
=========

* Mike Hommey's
  [Debian EFI mode boot on a Macbook Pro, without
  rEFIt](http://glandium.org/blog/?p=2830).
* Matthew Garrett detailed [the ISO images for Fedora 17 installation
  CD](http://mjg59.dreamwidth.org/11285.html) and [their Mac
  support](http://mjg59.dreamwidth.org/12037.html): it supports BIOS,
  UEFI, Mac platforms when burned to a CD or written directly to a USB
  stick. This might be nice for the ISO that Tails distribute, but not
  applicable to support USB sticks with incremental updates.
* <http://www.rodsbooks.com/refind>
* <http://refind.sf.net>
* <http://refit.sf.net/info/apple_efi.html>
* <http://osxbook.com/book/bonus/chapter4/efiprogramming>
* <http://osxbook.com/book/bonus/chapter4/firmware>
* <http://wiki.osx86project.org/wiki/index.php/EFI>
