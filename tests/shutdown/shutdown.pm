use strict;
use base "openQAcoretest";
use testapi;

sub run {
    wait_screen_change { send_key 'ctrl-alt-f2' };
    type_string "poweroff\n";
    assert_shutdown;
}

1;
