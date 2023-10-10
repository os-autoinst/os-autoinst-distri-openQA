use strict;
use base 'openQAcoretest';
use testapi;

use OpenQA::Wheel::OpenQATest::WebUI qw(login);

sub run {
    login;
}

1;
