use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_and_click 'openqa-home', 5;
    assert_screen 'openqa-dashboard', 5;
    assert_and_click 'openqa-build0001', 5;
    assert_screen 'openqa-buildresults', 5;
    assert_and_click 'openqa-passed-test', 5;
    assert_screen 'openqa-testresults', 5;
    assert_and_click 'openqa-needle', 5;
    assert_and_click 'openqa-needle-editor', 5;
    assert_and_click 'openqa-source-code', 5;
    assert_screen 'openqa-source-screen', 5;
}

1;
