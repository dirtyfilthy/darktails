Corresponding ticket: [[!tails_ticket 8573]]

We want to replace Pidgin with a more secure IM client.

This document lists our requirements and candidate clients, along with their pros and cons.

[[!toc levels=3]]

# Requirements

**Note**: the key words "MUST", "MUST NOT", "REQUIRED", "SHALL", 
"SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and 
"OPTIONAL" in this document are to be interpreted as described in 
[RFC 2119](http://www.ietf.org/rfc/rfc2119.txt).

## General requirements

### Use cases

The client SHOULD support the following use cases:

1. Use Tails' XMPP public and internal chatrooms
2. One-to-one chat that is compatible with currently widespread practice. That basically means XMPP + OMEMO, nowadays.

The client MAY support the following use cases:

* One-to-one chat that protects metadata end-to-end (that is: "who is chatting with whom")

### Documentation

### Internationalization

The client must be internationalized, ideally already translated in many languages - if not, adding new languages should be easy.

### GUI

The client must have a easy to use GUI that makes it hard for users to use the client in an insecure way.

### TLS

The client must support connections using TLS.

### Support for Tor

The client must support Tor and must not leak any private data (hostname, username, local IP, ...) at the application level.

### Support for OMEMO

The client must support OMEMO and should make it easy to enforce usage of OMEMO for all conversations or only for specific contacts.

Ideally, some usability study for the OMEMO user interface has been done.

Resources:

 - [clients support](https://omemo.top/)
 - [[!tails_gitlab 11541]]
 - [[!wikipedia OMEMO]]
 - [XEP-0384](http://xmpp.org/extensions/xep-0384.html)

### Support for OTR

The client MAY support OTR and make it easy to enforce usage of OTR for specific contacts.

### Other

TODO: Pidgin already has an apparmor profile; should we require that a replacement also comes with an apparmor profile?

The client MUST NOT save logs of conversations.

### Candidates

Suggested by sajolida on <https://mailman.boum.org/pipermail/tails-dev/2016-January/010123.html>:

* private group chat
* search and archive past public communications
* offline-friendliness
* <https://dymaxion.org/essays/pleasestop.html>

## XMPP (Jabber)

 *( Here is a [list](https://developer.pidgin.im/wiki/SupportedXEPs) of XMPP extensions supported by Pidgin )*

### MUC
The client must support XMPP conference rooms [(XEP-0045)](https://xmpp.org/extensions/xep-0045.html).

# Candidate alternatives 

## Dino

* [homepage](https://github.com/dino/dino)
* implemented in GTK+/Vala
* supports XMPP, OMEMO and OpenPGP; OTR support is
  [not high on the todo list](https://github.com/dino/dino/issues/97)
* Supports Tor, works in Tails. [Wiki page on Dino with Tor](https://github.com/dino/dino/wiki/Tor)
* is [[!debpts dino-im desc="in Debian"]] Buster
* the Debian maintainer wants to add an AppArmor profile and got in
  touch with intrigeri about it
* Translated into 25+ languages
* Small but quickly increasing popularity:
  <https://qa.debian.org/popcon.php?package=dino-im>
* Simple and modern-looking GUI
* Simple account setup wizard. First-run experience feels good. -- intrigeri
* Until 0.2.0 inclusive, requires valid TLS certificate, which prevents connecting to Onion XMPP servers:
  <https://github.com/dino/dino/issues/958>
* Reading encrypted OMEMO messages received from a Gajim user always worked out of the box.
* Sending encrypted OMEMO messages to a Gajim user did not work initially (looks
  like <https://github.com/dino/dino/issues/873> and
  <https://github.com/dino/dino/issues/206>). But it turns out it was a caused
  by a XMPP server that is known to have odd issues. It worked just fine
  with another XMPP server.

### Security

- 28k lines of Vala + 1k lines of C = 29k lines of code

- Track record:
  - In 2019, [Multiple protocol implementation
    errors](https://gultsch.de/dino_multiple.html) were discovered in Dino:

    - [[!cve CVE-2019-16237]]: an attacker can send messages in the name of someone else
      (previously found in other XMPP clients: CVE-2017-5589+)
    - [[!cve CVE-2019-16236]]: remote attackers can modify the roster (previously
      found in Gajim: CVE-2015-8688)
    - [[!cve CVE-2019-16235]]: does not properly check the source of a carbons message

    As that document says, "When confronted with the fact that the same trivial
    vulnerabilities have been discovered in multiple, independent clients one
    can not avoid the question if there is a more fundamental issue underneath
    that causes different developers to all make the same mistakes."
    Indeed, at the time, the corresponding XEPs lacked sufficient information
    to implement them securely.

- intrigeri's conclusion (2020-12-07):

  - Looks OK to me, but Dino is pretty recent
    and not widespread, so this could be a case that nobody bothered looking
    closely enough.

  - Dino's small feature set suggests it should be easy to confine it with AppArmor.

## Gajim

* XMPP client
* in Debian
* OMEMO plugin is in Debian Buster
* OTR v3 plugin is not in Debian
* People from Security-in-a-Box have used it successfully in Tails.
* Large established user base (<https://qa.debian.org/popcon.php?package=gajim>)
  for a XMPP client. Stagnating since about 10 years.
* Account setup wizard is confusing: when one wants to enable Tor, one also has to fill in
  other advanced settings.
* By default, tries to save passwords to the GNOME password store,
  which we decided is hard to persist. This can be disabled.
* Allows accepting an arbitrary TLS certificate, which allows connecting to
  Onion XMPP servers.

### Security

- 86k lines of Python + 2k for the OMEMO plugin = 88k lines of code

- D-Bus capabilities: can be disabled?

- Track record:
  - [[!cve CVE-2016-10376]]: allows being controlled by the XMPP server
  - [[!cve CVE-2015-8688]]: remote attackers can modify the roster and intercept
    messages
  - [[!cve CVE-2012-5524]]: custom SSL certificate verification callback
    accepted CA-signed certificates for any domain.
  - [[!cve CVE-2012-2085]] aka. https://dev.gajim.org/gajim/gajim/-/issues/7031:
    remote code execution by building command lines out of untrusted input.

- Gajim ships with a plugin called "plugin installer" which allows a user to
  download new plugins. This sounds suspicious for security, because plugins are
  pieces of code running with full privilege. The implementation in Debian use
  unverified TLS connection, which is very very open to MITM. The development
  version has switched to verified HTTPS connection and is trying to make it
  more robust.

  However, I think that Tails should not ship this plugin installer at all: it
  allows a user to download code without needing sudo. We could work debian-side
  to separate gajim-plugininstaller in a separate package so that Tails can
  choose not to install it?

- intrigeri's conclusion (2020-12-07):

  - Having tons of powerful features increases attack surface and the risk of
    secure programming mistakes. Gajim's security track record in 2012 is not
    confidence inspiring, to say the least. OTOH the worst problems happened
    many years ago, so perhaps the Gajim project has updated their processes to
    lower the risks of introducing other really bad security issues?

  - The plugin installer is not confidence inspiring either.

  - Gajim's large feature set suggests it may be hard to write an AppArmor
    profile that provides meaningful security, while not breaking too
    much functionality.

## Does not meet our requirements

### CoyIM

* [Homepage](https://coy.im/)
* [Github](https://github.com/coyim/coyim/)
* CoyIM only supports XMPP.
* CoyIM [is in Debian](https://tracker.debian.org/pkg/coyim)
* Support for multi-user chatrooms (MUC) is [in
  progress](https://github.com/coyim/coyim/projects/2) and lacks some
  important features such as having a persistent list of rooms
  persistently saved in the configuration
* Supports Tor, TLS, OTR
* Supports creation of random accounts.
* Supports importing accounts from Pidgin.
* No logging, no clickable links.
* Not audited.
* Test results in Tails: [[!tails_ticket 8574]]
* No OMEMO support.

### Thunderbird

- Thunderbird 75 Beta will support OTR after enabling the `chat.otr.enable`
  pref: <https://wiki.mozilla.org/Thunderbird:OTR>
* No OMEMO support: <https://bugzilla.mozilla.org/show_bug.cgi?id=1237416>

### Tor Messenger ([[!tails_ticket 8577]])

Tor Messenger is no more: https://blog.torproject.org/sunsetting-tor-messenger

* Documentation, downloads and tickets in Tor's [Trac](https://trac.torproject.org/projects/tor/wiki/doc/TorMessenger)
* Satisfies all our requirements (listed above, as of commit
  `8e3157d5f4cd7894bca21adf6b95a6b49d9beb01`) except the TODO about
  StartTLS (I bet it has the code for it though, since Thunderbird
  supports it, but I in the GUI there is only "Enable SSL" as options
  for XMPP).
* The GUI is very similar to Pidgin's, which might be a bonus point
  since we are looking for a "Pidgin replacement".
* It has support for "temporary XMPP accounts" that require no
  registration (no user input!) which would be useful for our support
  channel (see [[!tails_ticket 11307]]).
* Tor Messenger provides Linux packages but is not in Debian :(
* FWIW: Tor Messenger got 30K USD funding in 2017!
* FWIW: anonym has been happy using it exclusively for chatting since
  September, 2016.
* _Instantbird_ (on which _Tor Messenger_ is based) is dead upstream
  and is meant to be
  [replaced by future improvements in _Thunderbird_'s chat features](http://blog.queze.net/post/2017/10/18/Thunderbird-is-the-next-version-of-Instantbird)
  (although _Thunderbird_'s future is unclear as well). To follow
  along, subscribe to the [[!mozbug 1409891 desc="meta tracking bug"]]
  and the ones it depends on. The _Tor Messenger_ developers
  intend to
  [follow suit](https://lists.torproject.org/pipermail/tor-project/2017-October/001521.html)
  and create a _Tor Communicator_ bundle based on _Thunderbird_, that
  would handle both email and chat.
