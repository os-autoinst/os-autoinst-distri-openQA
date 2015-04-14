use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_screen "inst-bootmenu", 30;
    type_string "vga=791 ";
    type_string "Y2DEBUG=1 ";
    type_string "video=1024x768-16 ", 13;
    assert_screen "inst-video-typed", 13;
    send_key "ret";
}

1;
