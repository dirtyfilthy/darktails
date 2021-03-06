[[!toc levels=2]]

# What we don't want

Some users have requested support for VPNs in Tails to "improve" Tor's
anonymity. You know, more hops must be better, right?. That's just
incorrect -- if anything VPNs make the situation worse since they
basically introduce either a permanent entry guard (if the VPN is set
up before Tor) or a permanent exit node (if the VPN is accessed
through Tor).

Similarly, we don't want to support VPNs as a replacement for Tor
since that provides terrible anonymity and hence isn't compatible with
Tails' goal.

# What we might want

## Tails → Tor → VPN

Issue: [[!tails_ticket 5858]]

### Use cases

1. Access services that block Tor.
2. Reach a local resource on a VPN that is not accessible in any other
   way.
3. Reach a VPN non-anonymously (e.g. your account is tied to you IRL)
   while only hiding your geo-location, which may be the only thing
   you need in some situations. (Maybe invalid since this is not part
   of the PELD spec (yet?) AFAIK.)

### Solution

The easiest way to solve use case 1 (which we feel is the most
important one for this Tor/VPN setup) is to use a SSH connection with
the `DynamicForward` option. The newly created SOCKS port can be used to
have a fixed outgoing IP address. We could write on how to use that in
an "unsupported, advanced users only, may kill kittens" part of the
documentation.

Note that this setup isn't relevant for I2P for the same reason that
it's irrelevant for Tor hidden services.

## Tails → VPN → Tor/I2P

Issue: [[!tails_ticket 17843]]

### Use cases

1. Make it possible to use Tails at airports and other pay-for-use
   ISPs via iodine (IP-over-DNS).
2. Access Tor on networks where it's censored.
3. Some ISPs require their customers to connect to them through VPNs,
   especially PPTP. Tails is currently unusable for them out of the
   box.

### Solution

Use cases 1 and 3 are worthwhile to support, and should be rather easy
to implement.

For all other uses of this setup (e.g. 2) we already promote bridges
instead. Now that obfsproxy is included, it should cover all
our needs.
