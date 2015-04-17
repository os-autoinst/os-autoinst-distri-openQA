use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_and_click 'openqa-admin-link';
    assert_screen 'openqa-admin-users', 5;
    assert_and_click 'openqa-admin-medium-link';
    assert_screen 'openqa-admin-medium', 5;
    assert_and_click 'openqa-admin-machines-link';
    assert_screen 'openqa-admin-machines', 5;
    assert_and_click 'openqa-admin-testsuite-link';
    assert_screen 'openqa-admin-testsuite', 5;
    assert_and_click 'openqa-admin-jobgroup-link';
    assert_screen 'openqa-admin-jobgroup', 5;
    assert_and_click 'openqa-admin-assets-link';
    assert_screen 'openqa-admin-assets', 5;
    assert_and_click 'openqa-admin-workers-link';
    assert_screen 'openqa-admin-workers', 5;
}

1;
