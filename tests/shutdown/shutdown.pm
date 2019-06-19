use strict;
use base "openQAcoretest";
use testapi;

sub run {
    wait_screen_change { send_key 'ctrl-alt-f3' };
    type_string "poweroff\n";
    assert_shutdown(300);
}

sub post_fail_hook {
    # in case plymouth splash screen on shutdown hides some messages
    send_key 'esc' if check_screen('plymouth');
}

1;
