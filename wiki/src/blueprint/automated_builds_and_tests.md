[[!tag archived]]

[[!meta title="Automated builds and tests"]]

[[!toc levels=2]]

Rationale
=========

An automated build and test environment would be pretty useful to
ensure a few facts:

- new code does not break anything
- new build tools (`live-build`) and included software
  (`live-config`, `live-boot`) don't break anything
- updates pushed to the APT repositories we don't control (e.g. Debian's)
  don't break anything
- the quality of our releases is good enough
- power users get to test early images built from feature branches,
  or from `experimental`
- we can ask bug reporters to test an image built from a bugfix
  branch, and see if it fixes their problem

What we have
============

* A Jenkins instance running on lizard, that builds a few branches
  whenever they are pushed. Results [are available
  publicly](http://nightly.tails.boum.org/).
* A partially automated test suite:
  - [[documentation|contribute/release_process/test/automated_tests]]
  - [[setup|contribute/release_process/test/setup]]
  - [[usage|contribute/release_process/test]]
  - [[test cases|contribute/release_process/test]] that are not
    implemented yet.

Roadmap
=======

0. Complete phase one (**build and publish ISOs automatically**):
   fix all child tickets of
   [[!tails_ticket 5324]].
0. Run the test suite automatically on autobuilt ISOs:
   [[!tails_ticket 5288]]
0. See other tickets in the *Continuous Integration* category,
   and organize the next steps.

What we need
============

Automated tests
---------------

Ideally, every automatically built ISO should be automatically tested,
and the results displayed online.

Infrastructure
--------------

Putting automatic builds and automatic tests on the same physical
machine (while using
virtualization to separate concerns) saves hosting and bandwidth costs:
fresh images can be tested without being transferred.

In order to be able to build Tails in memory (which greatly speeds up builds)
and to properly test HIGHMEM memory wipes, the test server should have at
least 32 GB. Using KVM inside a KVM
virtual machine is supported by the "nested KVM" feature.
VirtualBox (Vagrant) in KVM is not supported as of March 2013.

We could set a threshold of tests that have to be successful before publishing
one daily build image. This would prevent too-broken images to spread out and
potentially harm users.

The setup of the automated build and test server should be done
with public Puppet modules.

More specific pages
===================

[[!map pages="blueprint/automated_builds_and_tests/*"]]
