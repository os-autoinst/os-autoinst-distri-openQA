use strict;
use base "openQAcoretest";
use testapi;

sub run {
    validate_script_output "/usr/share/openqa/script/client jobs state=running", sub { m/"running"/ };
    save_screenshot;
    type_string "clear\n";
}

1;
