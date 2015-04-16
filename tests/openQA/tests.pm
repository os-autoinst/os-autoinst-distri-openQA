use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_and_click 'openqa-test-link', 5;
    assert_screen 'openqa-testscreen', 5
}

1;
