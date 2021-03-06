It might be useful to use `zram` in Tails.

[[!toc levels=2]]

# Rationale

`zram` is a kernel module that makes it possible to use some amount of
RAM as compressed swap. This should allow using a bit more RAM than
what's really available.

# Roadmap

See [[!tails_ticket 5740]].

# Resources

## Tools

* [systemd unit files](https://github.com/mystilleef/FedoraZram)
* [[!ubupkg zram-config]] in Ubuntu: Upstart job to enable zram support

## Documentation

* [Fedora 33 System-Wide Change proposal: swap on zram](https://lwn.net/ml/fedora-devel/CA+voJeU21toz3y_EjfDv7ytiJhSEhJJM2070Cf8otLACobZcCQ@mail.gmail.com/)
  uses <https://github.com/systemd/zram-generator>
  ([third-party Debian packaging](https://github.com/nabijaczleweli/systemd-zram-generator.deb))
* [[!debpts zram-tools]] enables `zram` on boot
* [Gentoo wiki page about zram](https://wiki.gentoo.org/wiki/Zram)
* [Google is Enabling zRAM for Chrome OS By Default](http://www.chromestory.com/2013/03/google-enabling-zram-for-chrome-os-by-default/)
* Linux 3.8 ships a faster lzo compression module, that's used by zram
  ([commit](https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=10f6781c8591fe5fe4c8c733131915e5ae057826)).
* Ubuntu's Live systems have enabled compcache (zram's ancestor) in an
  initramfs script shipped by casper on systems with no more than
  512MB of RAM between Intrepid and Precise. Disabled in Quantal since
  compcache does not exist anymore.
* Daniel Baumann's [initial testing
  report](https://lists.debian.org/debian-devel/2012/01/msg00224.html)
  was quite sad:  "i've tested it quite a bit with the idea of
  enabling it automatically on debian-live systems if the machine as
  not a certain amount of physical ram available. had only bad
  experiences with it, so far (worse than without it)". He experienced
  "complete lockups/panics, and general 'so slow nearly death'
  experience of the system" on 1GB systems with no disk swap enabled.
  He was giving sometimes half, sometimes 3/4 of the system RAM to
  zram (<5162E7AB.3050302@progress-technologies.net>).

