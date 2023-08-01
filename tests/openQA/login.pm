use strict;
use base 'openQAcoretest';
use testapi;

sub run {
    assert_and_click 'openqa-login';
    assert_screen 'openqa-logged-in';
}

1;
