[[!tag archived]]

[[!toc levels=2]]

**Ticket**: [[!tails_ticket 6370 desc="#6370"]]

Current status
==============

The `feature/ff24` branch builds, boots and basically works fine.

Guidelines for testers
======================

1. **What to test?** — Test an ISO built from the `feature/ff24`
   branch. The most recent [nightly
   built](http://nightly.tails.boum.org/build_Tails_ISO_feature-ff24/)
   one should do. See the *Needs to be checked* section below, and
   test whatever should work fine in the Tails web browser.

1. **Information we need** — Always report the exact *commit* the ISO
   you are testing was built from (if it is a nightly built one,
   report its filename; if you built it yourself, you can get this
   information in *About Tails*).

1. **Reporting problems** — If you discover something suboptimal,
   first please check *Known issues* below and the sub-tasks of
   [[!tails_ticket 6370]]. Then, please check if it's a regression
   compared to the current stable Tails, and then:
   * If it is a regression, file a sub-task of [[!tails_ticket 6370]].
   * If it is not a regression, report a complete bug
     with WhisperBack.
   Note that the main goal of this testing session is *to discover
   regressions* in `feature/ff24`, and gain confidence in it;
   basically, everything else will be treated as low-priority.
   Let's keep focus, please :)

1. **Reporting success** — When something works fine, please add it to
   the *Known working* section below. If you don't have Git commit
   bit, and have no personal Tails Git repo, report success to the
   email thread on the tails-dev mailing list, or to intrigeri on IRC.

1. **If in doubt** — Ask intrigeri on IRC (`#tails-dev`).

Needs to be checked
===================

*Empty for now.*

Known issues
============

Fingerprinting
--------------

Comparing to TBB 3.0b1:

* ip-check.info says TBB 3.0b1 has JavaScript version 1.8, while the
  Tor browser 24.1 has version 1.5
  - It says 1.8 too for Tails 0.21 and TBB 2.3.25-14-dev, so that
    looks like a regression.
  - It says 1.5 too for iceweasel 24.1.0esr-1 and for Firefox 24.1,
    both running on Debian sid.
  - No downgraded package in that ISO vs. 0.21.

* ip-check.info returns a line "Screen" with Tails 0.21, TBB 2.4.17~rc1, and TBB
  3.0b1 running from inside Tails 0.22 but not with Tor browser 24.1:
  `Screen: 1000 x 567 pixels (inner size), Zoom: 100%`.

* ip-check.info returns a slightly different "Browser Window" size, even if run
  in the same context (freshly started browser in a virtual machine with the
  same screen size). That's [[!tails_ticket 6377]] and [[!tor_bug
  10095]], not much we can do about it yet.
  - `Browser window: 1000 x 600` with Tor browser 24.1
  - `Browser window: 1000 x 567` with Tails 0.21
  - `Browser window: 1000 x 591` with TBB 3.0b1
  - `Browser window: 1000 x 564` with TBB 2.4.17~rc1

Known working
=============

Basic fingerprinting
--------------------

A build from `feature/ff24` is seen by ip-check.info just the same way
is Tails 0.20.1's browser.

Comparing to TBB 3.0b1:

* panopticlick: same results, modulo screen size

Misc
----

- eepsites via I2P work
- Tor hidden services work

Persistent bookmarks feature
----------------------------

* bootstrapped on this branch
* created with an older Tails, upgrading

Working with tails-i386-feature_ff24-0.22-20131111T0855Z-10f5a19.iso.

Prefs
-----

... were cleaned up ([[!tails_ticket 5768]]), many were merged with
Torbrowser's ones, and they are in the intended state at runtime.

Unsafe browser
--------------

Successfully tested French, Portuguese (both Brazil's and Portugal's
flavours), German, and Arabic.

Repeatedly opening and closing works as expected.

Connects fine to the web as of 0f5eab28.
