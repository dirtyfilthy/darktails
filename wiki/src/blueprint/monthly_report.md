[[!meta title="Monthly reports"]]

[[!map pages="blueprint/monthly_report/**" show="title"]]

This page could be a good place to gather HOWTO, tips, template, etc.
for the monthly reports.

[[!toc]]

<a id="coordinators"></a>

Coordinators for the next reports
=================================

The month in the list corresponds to the month to be reported about. For
example, the report about April in the list will be written at the
beginning of May.

### 2021

  - January 2021: sajolida
  - February 2021: intrigeri
  - March 2021: sajolida
  - April 2021: ignifugo
  - May 2021: sajolida
  - June 2021: ignifugo
  - July 2021: intrigeri
  - August 2021: sajolida
  - September 2021: ignifugo
  - October 2021: sajolida
  - November 2021: ignifugo
  - December 2021: sajolida

### 2020

  - January 2020: sajolida
  - February 2020: ignifugo
  - March 2020: intrigeri
  - April 2020: sajolida
  - May 2020: ignifugo
  - June 2020: sajolida
  - July 2020: sajolida
  - August 2020: ignifugo
  - September 2020: intrigeri
  - October 2020: sajolida
  - November 2020: ignifugo
  - December 2020: emmapeel


Preparing the Monthly report
============================

Every month an automatic email reminder is sent to <tails-dev@boum.org>.

The curator has to answer to that email and remember to other teams to add their bits and set a date "2 days before" close the report and start publishing process.
So to be a curator you need to be subscribed to the dev-mailing list. Please [[do it|about/contact#tails-dev]] :)

You have 3 ways to work on the report:

* editing in the website (easier)

* editing in GitLab web interface

* editing using Git on your computer

You can find the page of the report in a list at the top of this page and edit the page of the report clicking on the key in the top right corner.


Publishing
==========
  
- If you have the commit bit on our main repo, you can do the
  publication:

  - Ensure the `meta date=` directive is set to today's date in RFC 2822 format
    (e.g. `date --rfc-2822`).
  - Move report to `news/report_YEAR_MO.mdwn`.
  - [[Build the website locally|contribute/build/website]] and check that it builds fine and the
    report renders well (e.g. no broken links that worked earlier only
    because the report was under `blueprints/`).
  - Commit.
  - Push.
  - Tweet about the report:
       - "In MONTH, we worked on [...] and more: https://tails.boum.org/news/report_YEAR_MO."
       - If you don't have access to our Twitter account send your text
         for the tweet along with your merge request for the report.
  - Email the [[simplified HTML version of the report|simplified]]:

          To: tails-dev@boum.org
          Cc: tor-project@lists.torproject.org
          Subject: Tails report for XXXXXXXX YYYY
          Reply-to: tails-dev@boum.org

    Do the following to compose an email in HTML in *Thunderbird*:

    1. Choose [[!img lib/open-menu.png alt="Menu" class=symbolic link="no"]]&nbsp;▸
       **Preferences**&nbsp;▸ **Accounts Settings**.

    2. In the **Composition & Addressing** tab of your email account,
       select **Compose messages in HTML format**.

    If your email client, like *Thunderbird* in Tails, doesn't allow you
    to send emails in HTML format, you can probably do so from the
    webmail application of your email provider.

  - Make sure that we already have a volunteer for next month, or
    otherwise raise the issue on <tails-dev@boum.org> and update the
    [[list of volunteers|monthly_report#coordinators]].

- Else, notify <tails-dev@boum.org> when you think that the report is ready for
  publication. Ideally, prepare a merge request that does most of the
  publication work described above, and send your text for the tweet in this
  merge request.

Checklist
=========

If you feel like it:

- Check [[reports written for sponsors|contribute/reports]]

Template
========

    \[[!meta title="Tails report for MONTH, YEAR"]]
    \[[!meta date="`date --rfc-2822` eg. Thu, 08 Feb 2018 07:21:15 +0000"]]
    \[[!pagetemplate template="news.tmpl"]]

    \[[!toc]]

    Releases
    ========

    \[[Tails VERSION was released on MONTH DAY|news/version_VERSION]] ((emergency release)?):

    XXX: Copy the "Changes" section of the release notes, and compact a bit:

    * Remove lines about software upgrade (that's not Tails itself).
    * Remove screenshots.
    * Remove "New features" and "Upgrades and changes" headlines.
    * Remove line about Changelog.

    Tails VERSION+1 is \[[scheduled for MONTH DAY|contribute/calendar]].

    Code
    ====

    XXX: If you feel like it and developers, foundation team, and RMs don't do it themselves,
         list important code work that is not covered already by the
         Release section (for example, the changes being worked on for
         the next version).

    Documentation and website
    =========================

    XXX: If you feel like it and technical writers don't do it
         themselves, explore the Git history:

             git log --patch --since='1 October' --until='1 November' origin/master -- "doc**.*m*" "about**.*m*" "support**.*m*" "install**.*m*" "upgrade**.*m*"

    User experience
    ===============

    XXX: If you feel like it and the UX team does not do it
         themselves, check the archives of tails-dev:
         <https://lists.autistici.org/list/tails-dev.html>

    Hot topics on our help desk
    ===========================

    XXX: Ask tails-bugs@boum.org to list hot topics for the last month.

    1.

    1.

    1.

    Infrastructure
    ==============

    Funding
    =======

    XXX: The fundraising team should look at the fundraising Git.

           git log --patch --since='1 December' --until='1 January' origin/master

    XXX: The fundraising and accounting teams should look at the archives of <tails-fundraising@boum.org> and <tails-accounting@boum.org>.

    Outreach
    ========

    Past events
    -----------

    Upcoming events
    ---------------

    On-going discussions
    ====================

    XXX: Link to the thread on <https://lists.autistici.org/list/tails-XXX.html>.

    Press and testimonials
    ======================

    XXX: Copy content from [[!tails_gitweb wiki/src/press/media_appearances_2020.mdwn]]
         This page is continuously updated by tails-press@boum.org, so if
         it's empty there might be nothing special to report.

    Translations
    ============

    XXX: Add the output of (adjust month!):

        sudo apt install intltool
        git checkout $(git rev-list -n 1 --before="September 1" origin/master) && \
        git submodule update --init && \
        ./wiki/src/contribute/l10n_tricks/language_statistics.sh

    Metrics
    =======

    * Tails has been started more than BOOTS/MONTH times this month. This makes BOOTS/DAY boots a day on average.

    \[[How do we know this?|support/faq#boot-statistics]]

    XXX: Ask <tails@boum.org> for this number.
