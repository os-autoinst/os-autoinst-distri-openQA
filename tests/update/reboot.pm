use strict;
use base 'openQAcoretest';
use testapi;
use utils;

sub run {
    enter_cmd 'systemctl reboot';
    wait_for_desktop;
}

1;
