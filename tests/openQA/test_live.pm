use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_and_click 'openqa-running-test', 5;
    assert_screen 'openqa-liveresults', 5;
}

1;
