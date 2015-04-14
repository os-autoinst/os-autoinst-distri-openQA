use strict;
use base "openQAcoretest";
use testapi;

sub run {
    validate_script_output "/usr/share/openqa/script/client isos post ISO=openSUSE-13.2-DVD-x86_64.iso DISTRI=opensuse VERSION=13.2 FLAVOR=DVD ARCH=x86_64 BUILD=1", sub { m/^[1-9][0-9]*$/ }; #Correct with real details for ISO=
    save_screenshot;
    send_key "ctrl-l";
}

1;
