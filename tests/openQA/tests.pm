use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_and_click 'openqa-test-link';
    assert_screen 'openqa-testscreen';
}

1;
