[[!tag archived]]

This documents the obsolete buildbot setup that was never lead to an
actually useful state.

# Automated builds

A buildbot instance automatically builds the `experimental`, `devel`,
`testing` and `stable` branches. No build result is currently
published due to bandwidth constrains, to there is no way for
developers or users to download the results yet.

# Setup

Our buildbot's instance runs inside a KVM guest managed by libvirt.

# What was left to do

0. Have the build failure notification sent to someone who wants to
   work on this.
1. Custom notifications when a build fails: the one currently sent
   lacks some useful information.
2. Request a mailing list where buildbot would send its build
   failure reports.
3. Move to a "build in a throw-away VM" approach, so that a given
   build cannot taint future ones.
4. Build *all* `feature/*` and `bugfix/*` branches.

