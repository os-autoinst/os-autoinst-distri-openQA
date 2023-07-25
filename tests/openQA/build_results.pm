use strict;
use base 'openQAcoretest';
use testapi;

sub run {
    assert_and_click 'openqa-build0002';
    assert_screen 'openqa-buildresults';
}

1;
