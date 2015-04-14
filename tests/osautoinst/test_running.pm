use strict;
use base "basetest";
use testapi;

sub run {
    validate_script_output "/usr/share/openqa/script/client jobs state=running", sub { m/^[1-9][0-9]*$/ };
    save_screenshot;
    send_key "ctrl-l";
}

1;
