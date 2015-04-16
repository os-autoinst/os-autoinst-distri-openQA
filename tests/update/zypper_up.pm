use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_screen "openqa-desktop", 500;
    send_key "ctrl-alt-f2";
    assert_screen "inst-console";
    type_string "root\n";
    assert_screen "password-prompt", 10;
    type_string "1\n";
    sleep 3;
    type_string "PS1=\$\n";
    sleep 1;
    script_run "systemctl mask packagekit.service";
    script_run "systemctl stop packagekit.service";
    save_screenshot;
    send_key "ctrl-l";
    script_run("zypper -n up --auto-agree-with-licenses && echo 'worked-up' > /dev/$serialdev");
    die "zypper failed" unless wait_serial "worked-up", 700;
    save_screenshot;
}

1;
