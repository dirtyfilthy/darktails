[[!tag archived]]

This is about [[!tails_ticket 5630]].

[[!toc levels=2]]

<a id="why"></a>

# Why we want reproducible builds

## List of reasons why

<div class="note">

Reproducible builds probably will not give us <emph>all</emph> these
advantages for free: some require additional work. Also, it might be
that some of these advantages are incompatible with each other.

</div>

* Allow independent verification that a build product matches what the
  source intended to produce ⇒ better resist attacks against build
  machines and developers (see
  <https://reproducible-builds.org/docs/buy-in/> for specific
  examples) ⇒ improves users' security, and allows developers to sleep
  better at night (as the incentive for an attacker to compromise
  developers' systems, or to compromise developers themselves, is
  lowered). In turn, this avoids the need to trust
  people (or software) who build the ISO we release, which in turn
  allows more people to get involved in release management work.

* We would not have to upload the ISO image anymore when we do a release: we
  could instead build it both on our infrastructure (Jenkins) and
  locally, compare the outputs, and if they match publish the ISO
  built by Jenkins. Uploading an ISO can take many hours with
  some commonly found means of accessing the Internet, so removing the need to
  go through this step decreases our time to remediation
  for fixing security issues, and makes it easier for developers
  with poor access to the Internet to take care of a release.

* Decrease the size of the IUKs ⇒ decrease the time needed by users to
  download upgrades ⇒ nicer UX, and makes it more likely that users upgrade in
  a timely manner instead of postponing to "when they have time".
  This depends e.g. on how we handle building with a fixed timestamp,
  and how we handle files metadata such as mtime when building an IUK.

* Limit the scope of the QA work that we have to conduct before
  putting out a bugfix release that has a small delta at the source
  level ⇒ decrease time to remediation (compared to having to test
  everything every time), and we can release security upgrades more frequently
  (e.g. every time a DSA affects us) because it is cheaper. We are
  indeed able to assess the impact of a specific update, when we know
  that everything else won't change when we build an ISO that includes
  this update, and we can verify it for example with diffoscope.

* No more bit flip that makes us waste precious hours during a release
  process (been there, seen that).

* Increases confidence in the value of our continuous quality
  assurance processes: it tests something that is be closer to what
  lands into the released binaries.

* Allow developers to use different build environments, while making
  sure that they produce the same binaries from the same source code.
  This is nice for developers (who get to pick their preferred tools),
  and also it helps ensure that we don't fully rely a golden trusted
  build environment, that must be absolutely never be compromised, and
  is very painful to upgrade.

* Increases the trust that users, and anyone interested really, can
  put into our released build products (such as ISO images) and our
  development and release process.

* Provides a baseline (system + configuration) that is more
  stable, and thus it is easier to maintain a delta against it, and
  easier to audit that delta in the ISO built from the modified
  source; e.g. another flavour of Tails we would support ourselves, or
  a rebranded Tails produced by some NGO, or a personal, custom built
  ISO that differs only by the addition of a few packages.

* Might save disk space on mirrors, if some block-level de-duplication
  is done by the filesystem, and the compression algorithms we use to
  build images is stable enough in the situations we use it for.

* Opens the door for cross-architecture building and verification of the build
  products, which:
  - decreases the risk that our build systems are all affected by the
    same architecture — or platform — specific security issue;
  - may allow us to support more architectures (e.g.
    [[!tails_ticket 10972 desc="ARM"]]), because we could do most our
    CI and QA on the fastest one.

* Detect bugs, for example the ones provided on the
  [reproducible builds project's buy-in page](https://reproducible-builds.org/docs/buy-in/)
  (retrieved on 2015-02-16):
  "[[!debbug 773916 desc="a library had a different application binary interface for every build"]],
  [[!debbug 801855 desc="garbled strings due to encoding mismatch"]],
  [[!debbug 778486 desc="missing translations"]],
  or [[!debbug 778707 desc="changing dependencies"]]".

* "The constraint of having to reflect about the build environment
  also helps developers to think about the relationship with external
  software or data providers. Relying on external sources with no
  backup plans might cause serious troubles in the long term"
  ([reproducible builds project's buy-in page](https://reproducible-builds.org/docs/buy-in/), 2015-02-16).

* Faster development processes: e.g. when one knows for sure that
  build stage 1 will produce the same output given the same input, one can cache it and
  build only stages 2 to n.

## Draft

<div class="note">

This draft needs to be updated. It was written in 2014, way before we
came up with the previous list of advantages, or discussed this topic
much. It was primarily meant to explain why we needed
a [[!tails_ticket 5926 desc="freezable APT repository"]], as a first
step towards reproducible builds.

</div>

Being free software is a necessary condition for tools to
be trusted for their security. The only way for *security researchers*
to know if a piece of software is trustworthy, is to audit its source
code.

But operating systems are delivered *to their users* in binary form that
cannot be simply reverted back to their original source code.

Of course, we provide ways for our users to strongly authenticate our
binaries using HTTPS and OpenPGP signatures. But there is no technical
way for security researchers to be sure that the binary delivered to the
users was built from the original source code, because the process of
transforming the source code into a binary is not deterministic: for
various reasons, compiling the same source code twice produces
different binaries.

Several free software projects such as Tor, Debian, and Bitcoin are
working on addressing this core issue of secure computing by making the
build process deterministic using new, innovative techniques.

Tails also wants to work towards reproducible
builds, in order to enable security researchers to audit our software more easily
and, as a consequence, to allow our users to put more trust in our
software.

<a id="how"></a>

# How we will make it happen

## Scope

We want to provide a verifiable path from human readable Tails source
code to the binary ISO images we publish. In other words, we want to
enable anyone (given sufficient technical skills and hardware
resources) to rebuild from source a given Tails release, in order to
independently verify that it matches the ISO image we have published.

We want our Quality Assurance (QA) and Continuous Integration
infrastructure to build Tails ISO images in a reproducible way, as
well: having this infrastructure test something that is be closer to
the binaries we'll release increases the value of our QA processes.

We want these properties to be easily maintainable on the long-term,
so we want to work with our upstreams (mainly Debian) towards making
as deterministic as possible the output of installing the software we
get from them.

As a welcome side-effect, the work towards Tails reproducible builds
will most likely provide other great benefits, including:

 * for Tails users: quicker access to security fixes, faster download
   of Tails upgrades, improved software quality;
 * for Tails contributors: improved QA processes, cheaper release
   process;
 * for the Free Software community: easier to make builds of other
   projects reproducible.

… but all these great potential outcomes depend on how exactly we
implement reproducible builds, so they are not explicitly part of the
scope of this project.

## Create and maintain suitable build environments

There are two main strategies available in order to get software build
reproducibly: always build it within the exact same context (e.g.
operating software, build tools, locales, system clock, hardware
architecture), or make the build process produce the same output
regardless of the context it runs in. These strategies are not
mutually exclusive, and for the sake of pragmatism, the other projects
who are working on reproducible builds combine them.

We pragmatically expect that we will need to do the same: we will
"freeze" the build context just enough to eliminate most variations
the build tools cannot cope with in a deterministic manner, and based
on this we will modify the build process itself, to make it
deterministic within this static build environment. Finding the right
place to draw the line between these two strategies will be an
interesting challenge.

So, we will create means to regularly "freeze" our build environment,
give a unique name to each such snapshot, and make them publicly
available. And we will also teach our ISO build system to use the
appropriate build environment depending on the branch or tag it is run
on. We think that our Vagrant-based build system can be extended to
support these new needs.

Thankfully, we have just unleashed our "freezable APT repository", so
it's totally doable to have a given frozen build environment use
software repositories that are frozen as well, which simplifies a lot
the creation and maintenance of frozen build environments: this avoids
the case when a software upgrade inside that frozen build environment
could modify it in a way that makes the build non-reproducible.

In passing, let's note that the build environment we need to record is
not limited a system disk image: various other things, such as the
type of virtualized CPU this system is started on, the number of CPU
cores, or the network configuration of the build virtual machine, also
affect the output of an ISO build. Here as well, we'll need to draw
a line between including such details into the description of the
build environment, and making the build system's output independent of
these variations.

It would also be good to make it easy to recreate a build environment
that's close to a given frozen one. It is out of the scope of this
first iteration, but we are confident that we can implement the above
in a way that makes it easy enough to add this property later.

## Implementation details

After lots of research, discussion and experiments, we settled on the
following implementation for our first iteration:

* To freeze the build environment, we use APT snapshots in the same way
  we do in the Tails build system, by storing the serials for the various
  APT repositories in
  [[!tails_gitweb_dir vagrant/definitions/tails-builder/config/APT_snapshots.d/]].
* Only the debian-security APT source uses Debian's APT repository, so
  that we get security fixes. This will probably not influence the
  reproducibility of the ISO. This is done in the
  [[!tails_gitweb vagrant/provision/setup-tails-builder desc="Vagrant provisioning
  script"]].
* To ensure that changes in the Vagrant build system are still taken into account when
  using a basebox, we dynamically set the name of the basebox by
  including the short ID of the last commit in the `vagrant` directory in
  the related branch, as well as its date, in the name of the basebox.
* We update the basebox APT snapshots serials when preparing a new Tails
  major release.
* A new VM is created from the basebox for each build. After the build,
  the VM is destroyed ([[!tails_ticket 11980]] and [[!tails_ticket 11981]]).
* The `keeprunning` build option can be used so that the VM is kept running
  and reused for subsequent builds of the same branch.
* The VM encodes (in `/var/lib/vagrant_box_build_from`) the branch for
  which it has been started for. The ISO build aborts if the branch being
  built is not the same as the one that is encoded in this file. This
  prevents the reuse of a running VM to build another branch than the
  one it has been started for initially.
* To ensure that the `apt-cacher-ng` cache is not lost when the VM is destroyed,
  it is stored in a dedicated virtual disk, and plugged into every new
  build VM.
  In our Jenkins setup we instead use an existing, external
  `apt-cacher-ng` in order to share the APT cache between build VMs
  and save disk space ([[!tails_ticket 11979]]).

So we don't publish Vagrant baseboxes anymore: everyone building
a Tails ISO image will instead build their own. Their resulting
basebox doesn't have to be identical to anybody else's, but it is
similar enough to produce ISO images that are identical to the ones
published by the Tails project.

**Edit:** It has now been released and is documented in the page about Tails
[[Vagrant setup|contribute/build/vagrant-setup]].

## Make Tails ISO build in a reproducible manner

We will modify the Tails ISO build process itself, to make it
deterministic within a given build environment.

This includes quite a few technical challenges, and we expect it will
be the most time-consuming part of this project. A number of those
challenges are being worked on as part of the broader reproducible
builds effort, and in particular in Debian, so we will benefit from
existing analysis regarding sources of non-determinism and possible
solutions. However, these efforts have been focused so far on building
smaller pieces of software (particularly Debian packages), so there is
little doubt we will hit new classes of problems while building a full
operating system image. Let us mention a few issues we already have in
mind:

 * Date and time: timestamps are the biggest source of reproducibility
   issues. In some cases we might be able to set the system clock to
   a predetermined value, in some others we need to have parts of the
   build process stop including timestamps, and then some additional
   post-processing should be enough to address all these issues.

 * Randomness: we have to deal with the fact that some random values
   are generated by the build system. In some cases we can simply seed
   a pseudo-random number generator with a predetermined value, but
   there may be cases when this would cause other problems.

 * Inputs from the network: we have already solved the biggest part of
   this problem thanks to our freezable APT repository, but there are
   more issues to address, as some Debian packages retrieve data from
   the network when they are installed. We already have a design in
   mind to solve this.

 * Debian packages' post-installation scripts: a lot of Debian
   packages include scripts that are run after the package is
   installed (typically to update databases, generate indices, etc.);
   in most cases, the output of these scripts is not deterministic.
   In many cases, we will be able to modify these scripts to make
   their output deterministic; but most likely, we will need a fair
   amount of post-processing to address at least some
   remaining issues.

We expect we will discover, along the way, a number of other
non-determinism problems we are not aware of yet. We are confident
that we can address them, and that our work will benefit other
projects that want to make their own builds reproducible (e.g.
operating system images for the cloud and embedded systems, operating
system installation media, other Live systems).

## Make it maintainable by pushing bits upstream

Let's not kid ourselves: the initial proof-of-concept of
a reproducible Tails ISO image build will probably rely on a lot of
ad-hoc post-processing.

But building reproducibly is a property that needs to be kept valid on
the long term: it would be a waste of our time to do all the work we
describe here if Tails ISO images stop building reproducibly, due to
upstream software changes, a year or two later. So we need to look at
this whole project through a long-term prism.

In practical terms, this means that as many as possible, among the
solutions we find to reproducibility issues, must end up _upstream_:
even if we use post-processing as part of a tracer bullet approach, we
will also work towards making as much of it as we can unneeded; for
example, by making the output of post-installation scripts for Debian
packages we ship deterministic. This is why no less than three Debian
package maintainers are part of the team we have assembled for
this project.

This work will also benefit other projects that want to make their own
builds reproducible, and even more so for Debian-based projects.

## Adjust our infrastructure accordingly

We will adapt our server infrastructure to support this project.

We will re-use the Vagrant-based build system we have created for
developers: that build system will need to support reproducible builds
anyway.

There are two aspects to it.

First of all, we will need to host a number of baseboxes that the
isobuilders will generate before each build (if locally unavailable).
This way they can re-use them rather than rebuild them each time. This
means having enough disk space for the `vagrant.d` directory in the
Jenkins user's home directory, as well as in the libvirt storage partition.

Secondly, we will enable our existing QA processes to build ISO
images:

 * when needed: in a fully reproducible manner (e.g. when building
   from a Git tag);
 * in the general case: in a way that minimizes the non-determinism of
   the output (we may want to use an up-to-date build environment
   instead of a frozen one).

Still, the integration into our Jenkins setup will require us to go
through a few additional steps, such as:

 * The virtual machines used as Jenkins "slaves" to build ISO images
   will need to store a number of different baseboxes.

 * We will use a rake task (`rake basebox:clean_old`) to clean
   obsolete baseboxes older than some time. Given we update the baseboxes at
   every Tails release, we've set this period to 4 months.

 * The Jenkins isobuilders will use the `forcecleanup` build option to ensure
   that the only copy of the baseboxes remaining on disk are the one in the
   `vagrant.d` directory, and every VM image in the libvirt storage pool is
   deleted, to avoid duplication of the basebox images.

 * For simplicity and security reasons, we will be using nested
   virtualization, i.e. Vagrant will start the desired ISO build
   environment in a virtual machine, all this inside a Jenkins "slave"
   virtual machine. We are already using nested virtualization a lot,
   so we are confident it can work out well, but still it brings two
   other problems. First, we have experienced reliability issues with
   nested virtualization in the past; these issues have been solved in
   the Linux kernel recently, but there may be more that our current
   use cases have not uncovered. And secondly, nested virtualization
   does not come for free: it has a cost in terms of performance and
   hardware resources, so in order for our continuous integration
   processes to keep up with our development cadence with a satisfying
   throughput, we might have to purchase and allocate more hardware
   to them.

For estimates on hardware cost for Lizard ([[!tails_ticket 12002]]), see [[the
dedicated page|blueprint/reproducible_builds/hardware]].

**Edit:** We already adapted our server infrastructure to support this project,
integrating it in our [[Vagrant setup|contribute/build/vagrant-setup]]
mentioned above. Specifics about how we deployed that in our Jenkins infra are
[[documented
here|contribute/working_together/roles/sysadmins/automated_builds_in_Jenkins]].

# Various ideas

## Debian (or nothing!) as trust anchor when building Tails

Note: this goal should probably not be part of our first iteration of
making Tails reproducible unless it turns out to be truly easy. But it
can be good to keep this potential future goal in mind so we don't
make decisions making it harder.

A possible goal for us could be that, when building Tails, delegate
the trust of the authenticity (here this means that a binary was built
from the claimed source code) of the binaries used, from the Tails
project (incl. infra) to the Debian project (incl. infra). This
includes both binaries used when building Tails, and the binaries that
end up inside the final Tails image. After all, the goal here is that
looking at the source and building it should be enough to authenticate
the images we ship.

In our custom APT repo we ship packages that we build ourselves, so we
need to make all of them build reproducibly for this goal to give any
real confidence. That includes both packages installed inside the
final Tails image (e.g. `tails-greeter`) and those used in the build
process (e.g. our patched `live-build`). Note that this would also be
nice to have in our QA process as a safe guard against contributors
uploading a (knowingly or not) compromised package, i.e. the reviewer
must be able to reproducibly build the same package.

In our frozen APT suites we allegedly ship tons of packages imported
straight from Debian. We should provide scripts that make it easy to
verify that that is the case, perhaps by downloading the needed signed
indexes/manifests etc from `snapshot.debian.org` and doing the
necessary checks. Or possibly even better: in each APT suite we can
include a package containing all the proofs needed to verify the
sources of all packages in the same suite, i.e. all
`dists/.../Packages`, `dists/.../Release{,.pgp}` and APT repo signing
keys used. That will make it easier to deal with non-Debian sources we
use (e.g. `deb.torproject.org`) that don't necessarily archive
historical APT repo state like `snapshot.debian.org` does. Users would
*only* need to authenticate all APT repo keys shipped in that package,
or similar. Hopefully Debian provides a way to authenticate obsolete
APT repo signing keys (e.g. by signing the old one with the new one)
so at least that part can be scripted/automated.

We also need to make it possible for users to generate the "static
build environment" (see above) themselves so they do not have to rely
on whatever binary blob (e.g. VM config + disk image) we
distribute. As already mentioned above, it should be possible to to do
this by leveraging our APT infrastructure's ability to freeze APT
state, which then can be verified as described above. Whatever the
users manage to produce does not need to be bit-by-bit identical with
binary blob we distribute; it just must have the same properties for
building Tails in a reproducible manner, which it should have provided
the frozen APT state used during generation.

(FWIW: given the experience we'll gather making Tails itself
reproducible, making the generation of the "static build environment"
reproducible is likely trivial in comparison. Having that would be
nice, but, as pointed out above, not necessary for this goal.)

Given all the above, users should be able to build Tails reproducibly
while only having had to trust Debian for any binaries used in the
process. Combine this with all Debian packages being reproducible at
some point and we're basically down to the "Reflections on Trusting
Trust" level when it comes to the "trust anchor", and close to reach
reproducability nirvana. I guess the next step would be to rely less
on a "static build environment" to support something like "Diverse
Double-Compiling" to counter the "Trusting Trust" problem. :)

# Jenkins

See "Adjust our infrastructure accordingly" above.


# Miscellaneous resources

* <https://reproducible-builds.org/>

* <https://wiki.debian.org/ReproducibleBuilds>

* <https://wiki.debian.org/ReproducibleInstalls>

* [[!tor_bug 3688]]

* Making POT files more stable: debconf 1.5.58's changelog entry reads
  "Don't update po/debconf.pot unless doing so changes something other than
  the POT-Creation-Date header.  The basic approach here is from gettext,
  though implemented a bit more simply since we can assume perl."

* Building Debian Live reproducibly:
  - see commits authored by "lamby" in
    [Webconverger's Debian live configuration](https://github.com/Webconverger/Debian-Live-config/commits/master),
    that include a script to clamp mtimes
  - [[!debbug 832998]] / [[!debbug 833118]]

* Making ISO filesystem reproducible:
  - ask Chris Lamb <lamby@debian.org> (keywords: libisofs,
    libisoburn, xorriso)
  - [[!debbug 831379]] / [[!debbug 832689]]

# Progress

See [[our May report|news/report_2017_05]].

# Future work

<a id="custom-Debian-packages"></a>

## Integrate custom Debian package builds in the automated ISO builds

<div class="note">
See discussion on [[!tails_ticket 6220]].
</div>

In our first iteration of reproducible ISO builds, we treat the
content of the Debian package repositories used during the build
process as trusted input. These repositories are of two kinds:

 * snapshots of the Debian archive, hosted on our own infrastructure,
   and signed server-side by our own key; Tails system administrators have the
   power to modify the content of these snapshots; an attacker who
   takes control of the relevant server can do the same; this will be
   improved later, and is outside of the scope of the work described
   in this section;

 * our [[custom APT repository|contribute/APT_repository/custom]],
   that stores our custom Debian packages; in addition to the people
   listed above (system administrators, successful attackers), Tails
   developers with commit rights can modify the content of this
   repository. The current standard process is that a developer builds
   a package locally, and uploads it to our custom APT repository.
   This entails a number of problems that we are going to discuss now.

Here are some problems that come with our current handling of custom
Debian packages:

 * Each developer needs to set up and maintain a local build
   environment for Debian packages. Such error-prone busywork is
   best avoided.

 * Our custom Debian packages may not build reproducibly across
   different developers' systems. So, one can't reproduce the build of
   a given ISO unless they use the exact packages that were uploaded
   to our custom APT repository. This brings the same
   [[set of problems|reproducible_builds#why]] that lead us to make
   our ISO image build reproducibly. For example, the state of our Git
   tree does not fully define what an ISO built from it will be, which
   makes reviewing and auditing harder than it should be.

 * Preparing a Tails release requires to build and upload a few
   packages by hand. This work is tedious and error-prone, and
   increases our time to mitigation for security issues.

 * Preparing a Tails release requires special credentials on our
   infrastructure, while we are moving towards Git access
   being enough.

The way we have chosen to address these problems in the future is to
have our custom Debian packages built automatically, in a reproducible
manner, as part of building a Tails ISO image.

There are a number of open questions:

 * Is it better to apply this build process change to _all_ ISO
   builds, or only to selected ones, e.g. actual releases?

 * Shall the Debian packages built as part of the ISO build be
   uploaded, stored and published somewhere? Or should they be
   considered as intermediate results we can just throw away after
   installing them?

 * If we upload these packages, how will they be verified by future
   builds using them?

 * How exactly shall these custom Debian packages be built? Can we do
   this inside the Vagrant build virtual machine?

 * What kind of quality assurance process will the built packages go
   through? Should it be done as part of the ISO build process, or
   instead on our continuous integration platform where the packages
   could be re-built (or uploaded) and checked?

Part of this project will therefore be to research and discuss these
topics with the affected parties, and come up with user stories and
with a fitting design.
