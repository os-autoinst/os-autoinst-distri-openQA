use strict;
use base "openQAcoretest";
use testapi;

sub run {
    send_key "ctrl-alt-f7";
    assert_screen "openqa-desktop", 15;
    x11_start_program("firefox", 6, { valid => 1 } );
    assert_screen 'openqa-dashboard', 35;
}

1;
