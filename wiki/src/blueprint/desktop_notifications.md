[[!tag archived]]

[[!toc levels=2]]

# The problem

[[!tails_ticket 7989]]

## Done

* `config/chroot_local-includes/usr/local/bin/tails-security-check`
  - Perl, `Desktop::Notify`, ported to notification actions
  - important enough to be noisy ⇒ ported to a dialog box
* `config/chroot_local-includes/usr/local/lib/tails-virt-notify-user`
  - Perl, `Desktop::Notify`, ported to a *transient* notification with
    an action, so clicking it does open the doc, but the notification
    disappears after 4 seconds
  - broken on Tails/Wheezy already (the link to the doc is not visible)
    ⇒ the current state of feature/jessie is not a regression, it
    actually improves things a bit.
* `config/chroot_local-includes/usr/local/sbin/tails-spoof-mac`
  - Shell, uses `notify-send` via
    [[!tails_gitweb config/chroot_local-includes/usr/local/sbin/tails-notify-user]]
  - broken on Tails/Wheezy already (the link to the doc is not
    visible, and one of the two possible links was broken anyway) ⇒
    the link to the doc has been removed for Tails 2.0, and a better
    solution can be found later ([[!tails_ticket 10559]]).
  - A second iteration could turn this into
    a dialog box: we now have an offline mode for those who want it,
    and else, if you want to be online, then MAC spoofing failure
    prevents you from using Tails in most cases so we can be noisy.
  - The notification code (`notify_panic_*`) that's started as
    a background process could advantageously be moved to the user
    session (it's probably a good idea to avoid starting background
    tasks in udev hooks, to avoid confusing udev wrt. when a hook has
    actually completed its work). To this end,
    `config/chroot_local-includes/usr/local/sbin/tails-unblock-network`
    could raise a flag so that a unit run in user session knows that
    it should notify the user (see e.g. the ugly `htp_done_file`, or
    find a better solution).
* `config/chroot_local-includes/usr/local/sbin/tails-restricted-network-detector`
  - Perl, uses `notify-send` via
    [[!tails_gitweb config/chroot_local-includes/usr/local/sbin/tails-notify-user]]
  - removed while, see [[!tails_ticket 10560]]


# Resources

## GNotification

* Needs GLib 2.40 (in Jessie).

* Intro: <https://wiki.gnome.org/HowDoI/GNotification>

* "applications using GNotification should be able to be started as
  a D-Bus service, using GApplication." =>
  <https://wiki.gnome.org/HowDoI/DBusApplicationLaunching>; this feels
  totally overkill for most cases when we currently use
  desktop notifications.

* "gnome-shell uses desktop files to find extra information (app icon,
  name) about the sender of the notification. If you don't have
  a desktop file whose base name matches the application id, then your
  notification will not show up". We'll see.

* intrigeri has a working Perl example with `add_button`. Next step is
  to pass parameters to the notification.

* If it's deemed overkill, or just too painful, to port every single
  script that needs to send notifications with actions to
  "GApplication + D-Bus activation + actions support" properly,
  a solution could be to let them all pretend to be the
  `org.boum.tails.OpenURL` or similar app in the simplest possible
  way, i.e. create a GApplication object merely to be able to send the
  notification or use the private D-Bus API to
  `org.gtk.Notifications`.
  
  And then, we need only one single real GApplication that can react
  to actions with parameters.
  
  A potential problem with this approach is that if a given
  GApplication is running already, another process pretending to be
  the same can't send notifications (reproducer code follows; the
  private D-Bus API allows to workaround this problem, but has other
  ones, read on). So, in practice if we go this way the URL opener app
  must have a lifetime close to zero, otherwise when clicking on
  multiple notifications buttons in a row, some actions won't be
  triggered (i.e. URLs won't be opened).
  
          #!/usr/bin/perl
          
          use strict;
          use warnings FATAL => 'all';
          use 5.10.1;
          
          use Gtk3;
          use Glib::Object::Introspection;
          
          Glib::Object::Introspection->setup(
              basename => 'Gio',
              version  => '2.0',
              package  => 'Gio'
          );
          
          my $app_id = 'org.gnome.gedit';
          my $app = Gtk3::Application->new($app_id, []);
          $app->register() || die "Could not register app";
          
          my $notification = Gio::Notification->new('My notification title');
          $notification->set_body("My notification body");
          $notification->add_button("OK", 'app.new-document');
          # If gedit is already running, this fails with:
          #   GLib-GIO-CRITICAL **: g_application_send_notification:
          #   assertion '!g_application_get_is_remote (application)' failed
          $app->send_notification("my-notification-id", $notification);

* private D-Bus API (`org.gtk.Notifications`):
  <https://wiki.gnome.org/Projects/GLib/GNotification> ... maybe an
  option whenever language bindings are not good enough, but so far
  I (intrigeri) was not able to add buttons to it:

          #!/usr/bin/perl
          use strict;
          use warnings FATAL => 'all';
          use 5.10.1;
          use Net::DBus;
          Net::DBus
              ->session
              ->get_service("org.gtk.Notifications")
              ->get_object("/org/gtk/Notifications")
              ->as_interface("org.gtk.Notifications")
              ->AddNotification('org.gnome.gedit', 'whatever-notification-id', {
                  title            => 'my notification title',
                  body             => 'my notification body',
                  # Works... when 'buttons' is not passed
                  'default-action' => 'app.new-window',
                  # Does not work, for some reason
                  buttons => [
                      { label => "New window",   action => "app.new-window"},
                      { label => "New document", action => "app.new-document"},
                  ],
              });

* GNOME Shell 3.16: non-default action buttons are only displayed when
  the notification pops up initially, _not_ in the [Message
  List](https://wiki.gnome.org/Design/OS/Notifications/#Message_List).
  Jessie's GNOME Shell (3.14) hasn't this problem. We can get away
  with only a default action that opens the URL we want, in the use
  cases we have in practice.
