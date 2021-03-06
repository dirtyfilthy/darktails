This is about [[!tails_ticket 16960]] and related tickets.

[[!toc levels=3]]

# Rationale

In 2016 we gave our main server some more RAM, as a temporary solution
to cope with our workload, and as a way to learn about how to scale
it. See [[blueprint/hardware_for_automated_tests_take2]] for our
reasoning, lots of benchmark results, and conclusions.

It's working relatively well so far, but we may need to upgrade again
soonish, and improvements are always welcome in the contributor UX
area:

 * Our release process suffers from a number of delays that are in the critical
   path and could be shortened if our Jenkins workers were faster: running the
   test suite after importing Tor Browser, building the final images to check
   for reproducibility, building IUKs.

 * When Jenkins has built an ISO from one of our main branches or from
   a branch that _Needs Validation_, since October 2017 we rebuild in
   in a slightly different build environment to ensure it can be
   [[rebuilt reproducibly|blueprint/reproducible_builds]].
   This increased substantially the number of ISO image we build
   which sometimes creates congestion in our CI pipeline (see below
   for details).

 * On our current setup, large numbers of automated test cases are
   brittle and had to be disabled on Jenkins (`@fragile`), which quite
   a few problematic consequences such as: it decreases the value our
   CI system brings to our development process, it is demotivating for
   test suite developers, it decreases the confidence developers have
   in our test suite, and it forces developers to run the full test
   suite elsewhere when they really want to validate a branch.
   Interestingly, we don't see this much brittleness anywhere else,
   even on a replica of our Jenkins setup that uses nested
   virtualization too.

 * As we add more automated tests, and re-enable tests previously
   flagged as fragile, a full test run takes longer and longer.
   We're now up to 300-350 minutes per run (depending on how many
   concurrent jobs are running) without fragile tests.
   We can't make it faster by adding RAM anymore nor by adding CPUs to ISO testers.
   But faster CPU cores would fix that. With a fast (Intel E-2134) CPU
   and a poor Internet connection, the same test suite (without fragile tests)
   only takes about twice less time.

 * Building our website takes a long while (11-15 minutes on our ISO
   builders on lizard, i.e. 20% of the entire ISO build time, which is
   56-70 minutes on lizard depending on how many concurrent jobs are running),
   which makes ISO builds take longer than they could. This will get worse as new
   languages are added to our website. This is a single-threaded task,
   so adding more CPU cores or RAM would not help: only faster CPU
   cores would fix that. For example, with a fast (Intel E-2134) CPU
   and a poor Internet connection, the ISO build only takes:
    - 25 minutes (including 5 minutes for building the website) on bare metal
    - 25 minutes for 1 concurrent build in a VM, i.e. using nested virtualization
    - 33 minutes (including ~5 minutes for building the website)
      for 2 concurrent builds in VMs, in the worst case situation (builds
      started exactly at the same time ⇒ they both need all their vCPUs
      at the same time)

 * Waiting time in queue for ISO build and test jobs is acceptable
   most of the time, but too high during peak load periods:

   - between 2017-06-17 and 2017-12-17:
     - 4% of the test jobs had to wait for more than 1 hour.
     - 1% of the test jobs had to wait for more than 2 hours.
     - 2% of the ISO build jobs had to wait more than 1 hour.

   - between 2018-05-01 and 2018-11-30:
     - We've run 3342 ISO test jobs; median duration: 195 minutes.
     - 7% of the test jobs had to wait for more than 1 hour.
     - 3% of the test jobs had to wait for more than 2 hours.
     - We've run 3355 ISO successful build jobs; median duration: 60 minutes.
     - 7.2% of the ISO build jobs had to wait more than 15 minutes.
     - 2% of the ISO build jobs had to wait more than 1 hour.
     - We've run 3355 `reproducibly_build_*` jobs; median duration: 70 minutes.
     - 10% of the `reproducibly_build_*` jobs had to wait more than 15 minutes.
     - 3.2% of the `reproducibly_build_*` jobs had to wait more than 1 hour.

   Not _that_ many jobs have to wait a long time, but this congestion happens
   precisely when we need results from our CI infra ASAP, be it
   because there's intense ongoing development or because we're
   reviewing and merging lots of branches close to a code freeze, so
   these delays hurt our development and release process.

 * Our current main server was purchased at the end of 2014. The hardware will
   hopefully last quite a few more years, but since it's now 5 years old, we've
   budgeted its replacement. If our CI run on another machine, replacing this
   main server would cost much less and the hardware would be chosen very
   differently.

 * The Tails community keeps needing new services; some of them need
   to be hosted on hardware we control for security/privacy reasons
   (which is not the case for our CI system):
   - Added already:
     - self-host our website
     - Schleuder
     - Weblate is a serious CPU, memory, and I/O consumer; besides, part of its
       job is to rebuild the website, which is affected by the single-threaded
       task performance limitations described above.
     - survey platform
   - Under consideration:
     - [[!tails_ticket 14601 desc="Matomo"]] will require huge amounts
       of resources and put quite some load on the system where we run
       it; it needs to be hosted on hardware we control.
     - [[!tails_ticket 9960 desc="Request tracker for help desk"]]):
       unknown resources requirements; needs to be hosted on hardware
       we control.
   - WIP and will need more resources once they reach production
     status or are used more often:

 * We're allowing more and more people to use our CI infrastructure. This may
   increase its resources needs eventually. From a development perspective,
   ideally every merge request would go through our CI, which probably
   requires a stronger separation between the CI workload and more
   security-sensitive tasks that we run.

# Options

<a id="new-bare-metal-server"></a>

## Bare metal server dedicated to CI

Hard to tell whether this would fix our test suite fragility problems,
hard to specify what hardware we need. If we get it wrong, likely we
have to wait another 5 years before we try again ⇒ we need to rent
essentially the exact hardware we're looking at so we can benchmark it
before buying.

Pros:

 * No initial development nor skills to learn: we can run our test
   suite in exactly the same way as we currently do.
 * Can provide hardware redundancy in case lizard suddenly dies.
 * We control the hardware and have a good relationship with
   a friendly collocation.

Cons:

 * High initial money investment… unless we get it sponsored or get
   a big discount from a vendor.
 * On-going cost for hosting a second server.

Extra options:

 * If we want to drop nested virtualization to get more performance,
   then we have non-negligible development costs and hard sysadmin
   problems to solve ([[!tails_ticket 9486]]):
   - We currently _reboot_ isotesters between test suite runs ⇒ if we
     go this way we need to learn how to clean up after various kinds
     of test suite failure.
   - Our test suite currently assumes only one instance is running on
     a given system ⇒ if we go this way we have to remove
     this limitation.

Specs:

 * For simplicity's sake, the following assumes we have Jenkins
   workers that are each able to run all the kinds of jobs we have,
   which would be a good idea anyway.
 * CPU: assuming 2 cores (4 hyperthreads) per Jenkins worker, for
   8 workers, we need 16 cores at ≥ 3.5 GHz base frequency, which is
   roughly equivalent to 4 × the Intel NUC mentioned below.
   Our options are:
    - 4 × [quad-core CPU](https://ark.intel.com/content/www/us/en/ark/search/featurefilter.html?productType=873&2_MarketSegment=Server&3_CoreCount-Min=4&3_CoreCount-Max=4&3_ClockSpeed-Min=3500&2_VTX=True&0_VTD=True&2_StatusCodeText=4&0_StatusCodeText1=3,4)
      (On 2020-02-04, 1 result with a not totally crazy price:
      [Xeon Gold 5222](https://ark.intel.com/content/www/us/en/ark/products/192445/intel-xeon-gold-5222-processor-16-5m-cache-3-80-ghz.html) → 4×105 W = 420 W)
    - 2 × [octo-core CPUs](https://ark.intel.com/content/www/us/en/ark/search/featurefilter.html?productType=873&2_MarketSegment=Server&3_CoreCount-Min=8&3_CoreCount-Max=8&3_ClockSpeed-Min=3500&2_VTX=True&0_VTD=True&2_StatusCodeText=4&0_StatusCodeText1=3,4)
      (On 2020-02-04, 1 result: [Xeon Gold
      6244](https://ark.intel.com/content/www/us/en/ark/products/192442/intel-xeon-gold-6244-processor-24-75m-cache-3-60-ghz.html) → 2 × 150 W = 300 W)
    - 1 × [16-core CPU](https://ark.intel.com/content/www/us/en/ark/search/featurefilter.html?productType=873&2_MarketSegment=Server&3_CoreCount-Min=16&3_ClockSpeed-Min=3500&2_VTX=True&0_VTD=True&2_StatusCodeText=4&0_StatusCodeText1=3,4)
      (On 2020-02-04, no result.)
    - Higher-density systems, with 2+ servers in a chassis e.g.
      Supermicro Twin solutions, might allow using cheaper CPUs that
      don't support multi-processor setups.
 * RAM:  
   + 232 GB = 29 GB × 8 Jenkins workers  
   + Jenkins VM + host system + a few accessory VMs  
   = round to 256 GB; 192 GB should work with super fast storage
   (at least 4 × NVMe × 2 for RAID-1) if that's cheaper
 * storage:  
   + 480 GB = 60 GB × 8 Jenkins workers  
   + 600 GB for the Jenkins artifacts store  
   +  70 GB for APT cacher (make it cache ISO history too)  
   + Jenkins VM + host system + a few accessory VMs  
   = round to 1.5 TB × 2 (RAID-1)

Cost estimate: $14-16k, depending on the chosen memory and storage setup
(based on <https://www.thinkmate.com/system/rax-xt24-42s1>
or <https://www.thinkmate.com/system/superserver-2029bt-dnc0r>).

<a id="gamer-option"></a>

## Bare metal gaming setup in a server housing dedicated to CI

CPU's targeted at the gaming sector are likely to provide the processing power we need, for a way lower price than regular server hardware. In particular, the new generation AMD Threadripper CPU's seem to be a good match. This would involve placing a gaming motherboard in a server casing.

Pros:

 * No initial development nor skills to learn: we can run our test
   suite in exactly the same way as we currently do.
 * Can provide hardware redundancy in case lizard suddenly dies.
 * We control the hardware and have a good relationship with
   a friendly collocation.
 * Relatively cheap

Cons:

 * On-going cost for hosting a second server.
 * No IPMI
 * Will require some research into cooling

Extra options:

 * We could get a KVM over IP device to compensate for the lack of IPMI
 * Or we could wait for a server board with TRX40 socket and IPMI support to enter the market

Specs:

 * The Threadripper 3960X has 24 cores at a 3.8Ghz base frequency. This easily meets our required 16 cores at ≥ 3.5 GHz base frequency.
 * A board like the Gigabyte TRX40 Aorus Xtreme can provide 256GB of DDR4 ECC memory and dual PCI-e 4.0 x8 1.6TB for storage.

Cost estimate: roughly 1k for the motherboard, 1.5k for the CPU, 2k for the memory, 1.5k for the storage, 0.5k for housing and extras ~= e6.5k for the most fancy version with super fast storage. Cutting down on the storage and motherboard could bring this down to roughly e5k.

<a id="hacker-option"></a>

## Custom-built cluster of consumer-grade hardware dedicated to CI, aka. the hacker option

For example, we could stuff 4 × Intel NUC or similar
together in a custom case, with whatever cooling, PoE and network boot
system this high-density cluster would need. Each of these nodes
should be able to run 2 Jenkins workers.

### Pros and cons

Pros:

 * Potentially scalable: if there's room left we can add more nodes in
   the future.
 * As fast, or actually even faster, as server-grade hardware.
 * We have one such node to play with and benchmark results already.

Cons:

 * Lots of initial research and development: casing, cooling, hosting,
   power over Ethernet, network boot, remote administration
 * High initial money investment
 * Hosting this is a hard sell for collocations. For example, the folks
   who'll do hardware debugging and parts replacement onsite may frown
   upon the extremely non-standard setup.
 * On-going cost for hosting this cluster.
 * Needs some development work to fully benefit from the performance
   improvements.

### Availability

 * Intel: in the ninth generation NUC9i7 (availability: 2020Q1),
   NUC9V7QNX is the one that supports vPro
 * Other vendors have started selling UCFF boards/kits with fast CPUs.
 * Similar smallish [[!wikipedia Computer_form_factor desc="form
   factors"]] would be worth investigating, e.g. there are plenty of
   [[!wikipedia Mini-ITX]] options on the market that could give us
   the high density we need.
   - [Supermicro X11SCL-IF](https://www.supermicro.com/products/motherboard/X11/X11SCL-iF.cfm), $200
     + <https://www.intel.com/content/www/us/en/products/processors/xeon/e-processors.html?Intel+Technology=900393> 300€
     + 2 × 16GB RAM Unbuffered ECC UDIMM, DDR4-2666MHz (e.g. CT16G4WFD8266) $400
     + CPU heatsink SNK-P0049A4 $50
     + mini-ITX case with power supply (e.g. Antec ISK310-150) 95€
     + SSD M.2 PCI-E 3.0 x4 250GB 90€
   - ASRock mini-ITX motherboards with IPMI that support suitable CPUs:
     E3C226D2I, E3C236D4I-44E85, EPC612D4I
   - Supermicro X10SDV series are affordable but support only too slow CPUs
   - nicer Supermicro options, e.g. X11SSV-M4F, are too expensive (1000€ for the motherboard only)
* Supermicro SuperServer E300-9D is very tempting (IPMI) but more
  expensive than a NUC.

Cost estimate: 7k€ for hardware (including shipping to the USA and import taxes)
and dozens of hours of custom work.

### Remote management

 * AMT (vPro) can be a pain as it shares the Ethernet interface
   with the OS. IPMI would be a big plus as it integrates well
   into the colo's existing setup.

<a id="hacker-option-benchmark"></a>

### Benchmarking results

Summary:

- Twice faster than lizard with 1 Jenkins executor on the node, that's
  able to run one build or test job at a time, without nested
  virtualization.

- With 2 Jenkins executors on the node, each in its own VM that's
  able to run one build or test job at a time, with nested virtualization,
  and qcow2 disks (probably slower than LVs as used on lizard):
  - light load, i.e. only one concurrent build/test: each build + test takes
    43% less time than on lizard
  - heavy load, i.e. two concurrent builds/tests: each build + test takes
    44% less time than on lizard

For detailed numbers, see above on this page: look for "E-2134".

So if we had, say, 4 such boxes in a case, each with 2 Jenkins
workers, in 24h they would build, reproduce and test ~55 branches.
While during the same period, the 9 VMs on lizard build, reproduce
and test ~40 branches. Even adding only 2 such boxes would
increase the maximum throughput of our CI by 69% and immensely lower
latency during heavy load times.

### Required development work

The above benchmarks assume perfect load distribution, which requires
Jenkins slaves that
can run both build and test jobs. It works fine in local limited
testing but this is not what we have set up on lizard at the moment:
there's a risk that a failed test job leaves the system in a bad shape
and breaks the following build job as we don't reboot after build
jobs. We might need to either make test jobs more robust on failure
([[!tails_ticket 17216]]),
or to start rebooting the Jenkins slaves after build jobs as well.

To utilize more fully such nodes, we may need to raise the number of
vCPUs allocated to TailsToaster. For example, assuming 8 hyperthreads
per box, and 2 VMs per box, with our current settings (2 vCPUs
allocated to TailsToaster and Cucumber eats another vCPU core):

 - when running 1 single test suite job,
   up to 3 hyperthreads out of 8 are used;

 - when running 2 concurrent test suite jobs,
   up to 2×3=6 hyperthreads out of 8 are used.

Raising this number may make the test suite run faster at least when
there's only 1 test suite job running. It might even make it faster,
in most scenarios, when 2 concurrent test suite jobs are running: they
generally won't be using that much CPU power at the same time. OTOH it
could introduce some test fragility.

We should first measure if it's worth the effort.

## Run builds and/or tests in the cloud

<div class="caution">
Some of the following numbers are outdated in the sense that they don't
take into account that we'll build and test USB images as well soon,
which impacts mostly the amount of data that need to be 1. transferred
between the Jenkins master and workers; 2. stored on the Jenkins master.
</div>

EC2 does not support running KVM inside their VMs yet. Both Azure and
Google Cloud support it. OpenStack supports it too as long as the
cloud is run on KVM (e.g.
[OVH Public Cloud](https://www.openstack.org/marketplace/public-clouds/ovh-group/ovh-public-cloud/),
[OSU Open Source Lab](https://osuosl.org/services/hosting/details/)).
ProfitBricks would likely work too as their cloud is based on KVM.

There's a Jenkins plugin for every major cloud provider that allows
starting instances on demand when needed, up to pre-defined limits,
and shuts them down after a configurable idle time.

After building an ISO, we copy artifacts from the ISO builder to the
Jenkins master (and thus to nightly.t.b.o), and then from the Jenkins
master to another ISO builder (if the branch _Needs Validation_ or one
of our main branches) and one ISO tester (in an case) that run
downstream jobs. These copies are blocking operations in our feedback
loop. So:

- If the network connection between pieces of our CI system was
  too slow, the performance benefits of building and testing
  faster may vanish.

  Assuming a 1.2 GB ISO, 3.5 minutes should be enough for a copy
  (based on benchmarking a download of a Debian ISO image from lizard)
  ⇒ 2 or 3 × 3.5 = 8 or 10.5 minutes for an ISO build; compared to 1.5
  minutes to the Jenkins master + 20 seconds to the 2nd ISO builder +
  15 seconds to the ISO tester =~ 2 minutes on lizard currently.
  In the worst case (Jenkins master on our infrastructure, Jenkins
  workers in the cloud) it adds 5 or 8.5 minutes to the feedback loop,
  which is certainly not negligible but is not a deal breaker either.

- If data transfers between pieces of our CI system costed money we
  would need estimate how much these copies would cost. On OVH Public
  Cloud, data transfers to/from the Internet are included in the price
  of the instance so let's ignore this.

One way to avoid this problem entirely is to run our Jenkins master
and nightly.t.b.o in the cloud as well.

Pros:

 * Scalable as much as we can (afford), both to react to varying
   workloads on the short term (some days we build and test tons of
   ISO images, some days a lot fewer), and to adjust to changing needs
   on the long term.
 * No initial money investment.
 * No hardware failures we have to deal with.
 * We can try various instances types until we find the right one, as
   opposed to bare metal that requires careful planning and
   somewhat-informed guesses (mistakes in this area can only be fixed
   years later: for example, choosing low-voltage CPUs, that are
   suboptimal for our workload).
 * Frees lots of resources on our current virtualization host, that
   can be reused for other purposes. And if we don't need these
   resources, then our next bare metal server can be much cheaper,
   both in terms of initial investment and on-going costs (it will
   suck less power).

Cons:

 * We need to learn how to manage systems in the cloud, how to deal
   with billing, and how to control these systems from Jenkins.

 * On-going cost: renting resources costs money every month.

   Very rough estimate, assuming we run all ISO builds and tests on
   dynamic OVH `C2-15` instances (4 vCores at 3.1 GHz, 15 GB RAM, 100
   GB SSD), assuming they perform exactly like my local Jenkins (4
   i7-6770HQ vCores at 2.60GHz, 15 GB RAM), and assuming that no VAT
   applies:

    - builds & tests:
      (30 minutes/build * 450 builds/month + 105 minutes/test * 350 tests/month)
      / 60 * 0.173€ = 145€/month
    - second build for reproducibility ([[!tails_ticket 13436]]):
      30 minutes / 60 * 250 builds/month * 0.173€ =  22€/month
    - total = 167€/month

   Now, to be more accurate:

    - Likely these instances will be faster than my local Jenkins,
      thanks to higher CPU clock rate, which should lower the actual
      costs; but only actual testing will give us more
      precise numbers.

    - Running a well chosen number of static instances would probably
      lower these costs thanks to the discount when paying per month.
      Also, booting a dynamic instance and configuring it takes some
      additional time, which costs money and decreases performance.

      We need to evaluate how many static instances (kept running at
      all times and paid per-month) we run and how many dynamic
      instances (spawned on demand and pay per-hour) we allow. E.g.
      on OVH public cloud, a dynamic C2-15 instance costs more than
      a static one once it runs more than 50% of the time. Thanks to
      the _Cluster Statistics_ Jenkins plugin, once we run this in the
      cloud we'll have the data we need to optimize this; it should be
      easy to script it so we can update these settings from time
      to time.

    - We need to add the cost of hosting our Jenkins master and
      nightly.t.b.o in the same cloud, or the cost of transferring
      build artifacts between that cloud and lizard.

      Our Jenkins master is currently allocated 2.6 GB of RAM and
      2 vcpus. An OVH S1-8 (13€/month) or B2-7 (22€/month) static
      instance should be enough. We estimated that 300 GB of storage
      would be enough at least until the end of 2018. Our metrics say
      that the storage volume that hosts Jenkins artifacts often makes
      good use of 1000-2000 IOPS, so an OVH "High Speed Volume"
      (0.08€/month/GB) would be better suited even though in practice
      only a small part of these 300 GB needs to be that fast, and
      possibly a slower "Classic Volume" might perform well enough.
      So:

       * worst case: 22 + 300×0.08 = 46€/month
       * best case: 13 + 300×0.04 = 25€/month

    - In theory we could keep running _some_ of our builds on our own
      infra instead of in the cloud: one option is that the cloud
      would only be used during peak load times for builds (but always
      used for tests in order to fix our test suite brittleness
      problems, hopefully). But if we do that, we don't improve ISO
      build performance in most cases, and the build artifacts copy
      problems surface, which costs performance and some development
      time to optimize things a bit:

       * If we run the Jenkins master on our own infra: only artifacts
         of ISO builds run in the cloud during peak load times need to
         be downloaded to lizard; we could force the 2nd ISO build to
         run locally so we avoid having to upload these artifacts to
         the cloud, or we could optimize the 2nd ISO build job to
         retrieve the 1st ISO only when the 2 ISOs differ and we need
         to run diffoscope on them (in which case we also need to
         download the 2nd ISO to archive it on the Jenkins master).
         But all ISO build artifacts must be uploaded to the nodes
         that run the test suite in the cloud.

       * If we run the Jenkins master in the cloud: most of the time
         we need to upload there the ISOs built on lizard; then we
         need to download them again for the 2nd build on lizard as
         well (unless we do something clever to keep them around for
         the 2nd build, or force the 2nd build to run in the cloud
         too); but at this point they're already available out there
         in the cloud for the test suite downstream job. During peak
         times, the difference is that ISOs built in the cloud are
         already there for everything else that follows (assuming we
         force the 2nd build to run in the cloud too).

 * We need to trust a third-party somewhat.

 * To make the whole thing more flexible and easier to manage, it
   would be good to have the same nodes able to run both builds and
   tests. Not sure what it would take and what the consequences
   would be.

We could request a grant from the cloud provider to experiment with
this approach.
See
[Arturo's report about how OONI took advantage of the AWS grant program](https://lists.torproject.org/pipermail/tor-project/2017-August/001391.html).

## Dismissed options

### Replace lizard

Dismissed: our CI workload has too specific needs that are better
served by dedicated hardware; trying to host everything on a single
box leads to crazy hardware specs that are hard to match.

Pros:

 * No initial development nor skills to learn: we can run our test
   suite in exactly the same way as we currently do.
 * On-going cost increases only slightly (we probably won't get
   low-voltage CPUs this time).
 * We can sell the current hardware while it's still current, and get
   some of our bucks back.

Cons:

 * High initial money investment.
 * Hard to tell whether this would fix our test suite fragility
   problems, and we'll only know after we've spent lots of money.
 * Hard to specify what hardware we need. If we get it wrong, likely
   we have to wait another 5 years before we try again.

<a id="plan"></a>

# The plan

1. <strike>Check how the sysadmins team feels about the cloud option: are
   there any blockers, for example wrt. ethics, security, privacy,
   anything else?</strike> → we're no big fans of using other people's
   computers but if that's the best option we can do it

2. Keep gathering data about our needs while going through the next steps:
   - upcoming services [intrigeri] (last updated: 2020-02-04)

3. Describe our needs for each option:
   - 2nd bare metal server-grade machine:
     * <strike>hardware specs [intrigeri]</strike> [DONE]
     * <strike>hosting needs (high power consumption)</strike> [DONE]
   - the gamer option:
     * <strike>hardware specs [groente]</strike> [DONE]
     * <strike>hosting needs (high power consumption)</strike> [DONE]
     * KVM over IP?
   - <strike>the hacker option: hosting</strike>
     [CANCELED: we won't do the hacker option]

5. Ask potential hardware/VMs donors (e.g. ProfitBricks) if they
   would happily satisfy our needs for free or with a big discount.
   If they can do that, then let's do it. Otherwise, keep reading.
   [WIP: intrigeri]

6. <strike>Benchmark how our workload would be handled by the options we have
   no data about yet:</strike>
   - <strike>Rent a bare metal server for a short time, run CI jobs in
     a realistic way, measure.</strike> [CANCELED: we have data about
     Intel E-2134 which is good enough.]
   - Find a friend who's really into gaming and has a threadripper setup to
     run some CI jobs in a realistic way, measure.
   - <strike>Rent cloud VMs for a short time, run CI jobs in a realistic way,
     measure.</strike> [CANCELED: we won't do cloud.]

7. Decide what we do and look into the details e.g.:
   - bare metal options: where to host it?
   - <strike>cloud: refresh list of suitable providers, e.g. check if more
     providers offer nested KVM, if the OSU Open Source Lab offering
     is ready, and ask friendly potential cloud providers such as
     universities, HPC cluster admins, etc.</strike> [CANCELED: we won't do
     cloud]
