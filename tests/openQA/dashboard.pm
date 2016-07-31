use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub run {
    send_key "ctrl-alt-f7";
    wait_for_desktop;
    x11_start_program("firefox http://localhost", 6, { valid => 1 } );
    assert_screen 'openqa-dashboard', 60;
}

1;
