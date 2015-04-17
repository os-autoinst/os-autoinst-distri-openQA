use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_and_click 'openqa-login';
    sleep 5;
    assert_screen 'openqa-logged-in', 10;
}

1;
