[[!tag archived]]

[[!meta title="Jenkins resources"]]

[[!toc levels=2]]

Miscellaneous
=============

- [Jenkins Best
  Practices](https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+Best+Practices)
- [plugins](https://wiki.jenkins-ci.org/display/JENKINS/Plugins)
  * [Git plugin](https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin)
  * [Copy Artifact
    plugin](https://wiki.jenkins-ci.org/display/JENKINS/Copy+Artifact+Plugin)
    can be used to run a test job against the result of a build job,
    e.g. for Debian packages (think Lintian) or Tails ISO images; see
    [grml's setup
    documentation](http://jenkins-debian-glue.org/getting_started/manual/)
    that uses it.
- the [jenkins](http://jujucharms.com/charms/precise/jenkins) and
  [jenkins-slave](http://jujucharms.com/charms/precise/jenkins-slave)
  JuJu charms may be good sources of inspiration for deployment
- [[!cpan Net-Jenkins]] (not in Debian) allows to interact with
  a Jenkins server: create and start jobs, get information about
  builds etc.

Jobs management
===============

- [Job builder](http://ci.openstack.org/jenkins-job-builder/) provides
  one-way (Git to Jenkins) jobs synchronization; it's in Debian sid.
  * [configuration documentation](http://ci.openstack.org/jenkins-job-builder/configuration.html)
  * Debian uses it in their `update_jdn.sh`: it runs `jenkins-jobs
    update $config` after importing updated YAML job config files
    from Git.
  * Tor [use
    it](https://gitweb.torproject.org/project/jenkins/jobs.git/tree) too.
- jenkins.debian.net uses the [SCM
  Sync](https://wiki.jenkins-ci.org/display/JENKINS/SCM+Sync+configuration+plugin)
  plugin, that apparently handles committing to the VCS on
  configuration changes done in the web interface, and maybe more.
- [jenkins-yaml](https://github.com/varnish/jenkins-yaml) might make
  it easy to generate a large number of similar Jenkins jobs, e.g.
  one per branch
- [jenkins_jobs puppet module](http://tradeshift.com/blog/tstech-managing-jenkins-job-configurations-by-puppet/)

Web setup
=========

### Visible read-only on the web

We'd like our Jenkins instance to be visible read-only on the web.
We'd rather not rely on Jenkins authentication / authorization to
enforce this read-only policy. We'd rather see the frontend reverse
proxy take care of this.

The
[`getUnprotectedRootActions()`](http://javadoc.jenkins-ci.org/jenkins/model/Jenkins.html#getUnprotectedRootActions())
method should return the list of URL prefixes that we want to allow.
And we could forbid anything else.

The [Reverse Proxy
Auth](https://wiki.jenkins-ci.org/display/JENKINS/Reverse+Proxy+Auth+Plugin)
Jenkins plugin can be useful to display [an example
usage](https://github.com/jenkinsci/reverse-proxy-auth-plugin/commit/72567a974960be2363107614ba3f705ec6e9b695)
of this method.

### Miscellaneous

- [sample nginx configuration](https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu)

Notifications
=============

- [IRC plugin](https://wiki.jenkins-ci.org/display/JENKINS/IRC+Plugin),
  but I'm told that the jenkins email notifications are way nicer
  than what this plugin can do, so see [a better way to do
  it](http://jenkins.debian.net/userContent/setup.html#_installing_kgb_client)
- [[!cpan Jenkins-NotificationListener]] is a server that listens to
  messages from Jenkins [Notification
  plugin](https://wiki.jenkins-ci.org/display/JENKINS/Notification+Plugin).

### Notifying different people depending on what triggered the build

At least the obvious candidate (Email-ext plugin) doesn't seem able to
email different recipients depending on what triggered the build
out-of-the-box. But apparently, one can set up two 'Script - After
Build' email triggers in the Email-ext configuration: one emails the
culprit, the other emails the RM. And then, they do something or not
depending on a variable we set during the build, based on what
triggered the build. Likely the cleaner and simpler solution.

Otherwise, we could have Jenkins email some pipe script that will
forward to the right person depending on 1. whether it's a base
branch; and 2. whether the build was triggered by a push or by
something else. This should work if we can get the email notification
to pass the needed info in it. E.g. the full console output currently
has "Started by timer" or "Started by an SCM change", but this is not
part of the email notification. Could work, but a bit hackish and all
kinds of things can go wrong.

Also, I've seen lots of people documenting crazy similar things with
some of these plugins: "Run Condition", "Conditional BuildStep",
"Flexible Publish" and "Any Build step". But then it gets too
complicated for me to dive into it right now.

How others use Jenkins
======================

-  jenkins.debian.net's:
   * [setup documentation](http://jenkins.debian.net/userContent/setup.html)
   * configuration: `git://git.debian.org/git/users/holger/jenkins.debian.net.git`
- [Tor's jobs](https://gitweb.torproject.org/project/jenkins/jobs.git/blob/HEAD:/jobs.yaml)
- [Ubuntu QA Jenkins instance](https://jenkins.qa.ubuntu.com/)
- grml's Michael Prokop talks about autotesting in KVM during his
  [talk at DebConf
  10](http://penta.debconf.org/dc10_schedule/events/547.en.html);
  they use Jenkins:
  * [Jenkins instance](http://jenkins.grml.org/)
  * [unittests](https://github.com/grml/grml-unittests)
  * [debian-glue Jenkins plugin](https://github.com/mika/jenkins-debian-glue)
  * [kantan](https://github.com/mika/kantan): simple test suite for
    autotesting using Grml and KVM
  * [Jenkins server setup documentation](https://github.com/grml/grml-server-setup/blob/master/jenkins.asciidoc)
- [jenkinstool](http://git.gitano.org.uk/personal/liw/jenkinstool.git/)
  has the tools Lars Wirzenius uses to manage his CI (Python projects
  test suite, Debian packages, importing into reprepro, VM setup of
  all needed stuff); the whole thing is very ad-hoc but many bits
  could be used as inspiration sources.

Jenkins for Perl projects
=========================

* [a collection of links](https://wiki.jenkins-ci.org/display/JENKINS/Perl+Projects)
  on the Jenkins wiki
* an overview of the available tools: [[!cpan Task::Jenkins]]
* [a tutorial](https://logiclab.jira.com/wiki/display/OPEN/Continuous+Integration)
* [another tutorial](http://alexandre-masselot.blogspot.com/2011/12/perl-hudson-continuous-testing.html)
* use [[!cpan TAP::Formatter::JUnit]] (in Wheezy) rather than the Jenkins TAP plugin
* use `prove --timer` to know how long each test takes

