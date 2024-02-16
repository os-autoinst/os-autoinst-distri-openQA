use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

sub _prevent_inactivity_timeout {
    my $desktop_runner_hotkey = check_var('DESKTOP', 'minimalx') ? 'ctrl-alt-spc' : 'alt-f2';
    send_key $desktop_runner_hotkey;
    assert_screen 'desktop-runner';
    mouse_hide 1;
    wait_still_screen 2;
    type_string 'xset s off -dpms';
    send_key 'ret';
}

sub run {
    wait_for_desktop;
    _prevent_inactivity_timeout;
}

1;

