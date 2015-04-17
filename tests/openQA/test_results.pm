use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_and_click 'openqa-home';
    assert_screen 'openqa-dashboard', 5;
    assert_and_click 'openqa-build0001';
    assert_screen 'openqa-buildresults', 5;
    assert_and_click 'openqa-passed-test';
    assert_screen 'openqa-testresults', 5;
    assert_and_click 'openqa-needle';
    assert_screen 'openqa-screenshot', 5;
    assert_and_click 'openqa-needle-editor';
    assert_screen 'openqa-needle-editor-screen', 5;
    assert_and_click 'openqa-source-code';
    assert_screen 'openqa-source-screen', 5;
}

1;
