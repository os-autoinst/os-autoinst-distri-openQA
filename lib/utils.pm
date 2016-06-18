package utils;

use base Exporter;
use Exporter;
use strict;
use testapi;

our @EXPORT = qw/wait_for_desktop/;

sub wait_for_desktop {
    check_screen [qw/boot-menu openqa-desktop/];
    send_key 'ret' if match_has_tag 'boot-menu';
    assert_screen "openqa-desktop", 500;
}

1;
