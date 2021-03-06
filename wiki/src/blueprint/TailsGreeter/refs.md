[[!tag archived]]

Collection of useful resources which might help to better understand project internals.

## Python implementation of GDM greeter

* [[http://doctormo.org/tag/gdm/]] - author's blog
* getting source code: bzr branch lp:gdm-commmunity-greeter

## Dependencies

* community-greeter (and hence tails-greeter) depends on gtkme package by the same author:
* getting source code: bzr branch lp:~doctormo/doctormo-random/gtkme

## Related projects

* [[https://code.launchpad.net/gdm-commmunity-greeter/]] - project upon which tails-greeter is initially based on.
* [[https://launchpad.net/~doctormo/+archive/greeter/+packages]] - ubuntu packages for gdm-commmunity-greeter
* [[https://code.launchpad.net/~doctormo/doctormo-random/gtkme]] - Python's GTK extension which allows run-time localization.
* [[http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=629199]] - RFP for python-gtkme package

## User interface

* [Fedora's language/locale/timezone table](http://git.fedorahosted.org/git/?p=anaconda.git;a=blob;f=data/lang-table;h=50f7be193328795ca5851cfab065a19d93672b03;hb=HEAD)
* thoughts about [Ananconda Language & Keyboard Layout
  Selection](http://blog.linuxgrrl.com/2011/07/06/anaconda-language-keyboard-layout-selection/):
  both what Anaconda current offers (very similar to the Debian
  Installer) and their future plans are better than current
  tails-greeter, and greatly inspiring
* GNOME 3.1 login screen (shell-style greeter + initial setup tool):
  [rationale and description](https://live.gnome.org/ThreePointOne/Features/LoginScreen),
  [screenshots](https://live.gnome.org/GnomeOS/Design/Whiteboards/LoginScreen)
* [Anaconda UX redesign
  plan](http://blog.linuxgrrl.com/2011/06/16/making-fedora-easier-to-use-the-installer-ux-redesign/),
  based on the [Hub and
  Spoke](http://www.time-tripper.com/uipatterns/Hub_and_Spoke) UI
  pattern
