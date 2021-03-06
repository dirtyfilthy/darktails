[[!tag archived]]

This is about [[!tails_ticket 12002]].

[[!toc levels=2]]

# Disk space

## isobuilders

### root

Was: 4G

Added 1G due to having more packages pulled with the Vagrant-libvirt
move, the upgrade to Stretch, and to have some margin for system upgrades.
Won't grow that much in the future. Only for Buster upgrade, which may
be in quite a long time if we use Stretch LTS.

-> 5G (+1G * 4)

### /var/lib/jenkins

Was: 6G

Needs to host:

 * 13 baseboxes 13 * 1.5G ~=> 20G
 * 1 basebox build 25G

-> 160G (+40G * 4)

### /var/lib/libvirt/images

Was: none

New needs:

* 1 basebox 2G
* 1 snapshot  2.5G

-> 20G (+5G * 4)

### Total disk space cost on isobuilders

185G

## Jenkins artifacts

Reproducible builds will add one ISO each time a build is not
reproduced. It's difficult to guess how often it will happen. Let's
consider 20% of the time worst case.

We host (as of 2017-07-01) around 150G of build artifacts, which means
we'll need (with the above ratio) 30G.

-> +50G

## time-based APT snapshots

We settled on using the same than the one used for the stable branch. So
that won't add more snapshots to keep around.

But we'll still have from time to time to use a different snapshots e.g
when working on the build system itself. We should probably aim at being
able to host 3 more time-based snapshots during two Tails release cycle.

The 2.12 time-based snapshot took around 40G of disk. With the arm ratio,
we'd need that +45% of it, and an additional 1.3 factor for the whole
Debian archive growth. So for 3 more snapshots, that'd take us:

-> +235G

## Total disk space cost

For 4 isobuilders, artifacts and the time-based snapshots: 470G

# Memory

## isobuilders

In 2015-08 we had 9G, then before switching to vagrant-libvirt we had
13.5G, and now we have 14.5G.

So the growth we've seen so far is:

 * +4G (+1G * 4) for reproducible builds only
 * +18G (+4.5G * 4) for upgrading the Tails ISO to Jessie and then Stretch

Currently, the available memory can get as low as 250M free when
compressing the SquashFS, so we're close to the limit.

We will probably have to add more RAM soon, especially since we may
start building ISO images based on Buster soon.

Let's assume switching to Buster requires another +3G bump per
isobuilder, and then the extra storage we need is:

 * +4G (+1G * 4) for reproducible builds
 * +12G (+3G * 4) for upgrading the Tails ISO to Buster

-> 16G

# CPUs

## isobuilders

We use 4 per isobuilder. This ratio will probably not change, but we
will need more when we'll add more isobuilders to cope with the charge.

# More isobuilders

With the reproducible builds we have a lower build output time,
meaning we will want to add more isobuilders in the future, or make
them faster. This is being researched on
[[blueprint/hardware_for_automated_tests_take3]].
