use strict;
use base "openQAcoretest";
use testapi;

sub run {
    type_string "systemctl reboot\n";
    assert_screen "openqa-desktop", 500;
}

1;
