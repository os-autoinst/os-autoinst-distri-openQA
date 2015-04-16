use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_and_click 'openqa-admin-link', 5;
    assert_screen 'openqa-admin-users', 5;
    assert_and_click 'openqa-admin-medium-link', 5;
    assert_screen 'openqa-admin-medium', 5;
    assert_and_click 'openqa-admin-machines-link', 5;
    assert_screen 'openqa-admin-machines', 5;
    assert_and_click 'openqa-admin-testsuite-link', 5;
    assert_screen 'openqa-admin-testsuite', 5;
    assert_and_click 'openqa-admin-jobgroup-link', 5;
    assert_screen 'openqa-admin-jobgroup', 5;
    assert_and_click 'openqa-admin-assets-link', 5;
    assert_screen 'openqa-admin-assets', 5;
    assert_and_click 'openqa-admin-workers-link', 5;
    assert_screen 'openqa-admin-workers', 5;
}

1;
