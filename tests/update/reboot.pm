use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub run {
    type_string "systemctl reboot\n";
    wait_for_desktop;
}

1;
