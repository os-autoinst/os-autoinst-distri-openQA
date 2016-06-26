package utils;

use base Exporter;
use Exporter;
use strict;
use testapi;

our @EXPORT = qw/wait_for_desktop/;

sub wait_for_desktop {
    check_screen [qw/boot-menu openqa-desktop/];
    send_key 'ret' if match_has_tag 'boot-menu';
    if (match_has_tag('openqa-desktop-locked')) {
        send_key 'esc';
        wait_still_screen(1);
        type_string $testapi::pasword . "\n";
    }
    assert_screen "openqa-desktop", 500;
}

1;
