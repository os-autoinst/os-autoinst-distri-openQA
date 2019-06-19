use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub run {
    wait_for_desktop;
    send_key "ctrl-alt-f3";
    assert_screen "inst-console";
    type_string "root\n";
    assert_screen "password-prompt";
    type_string "1\n";
    wait_still_screen(2);
    script_run 'systemctl mask --now packagekit';
    save_screenshot;
    type_string "clear\n";
    assert_script_run('zypper -n up --auto-agree-with-licenses', timeout => 700, fail_message => 'zypper failed to update packages');
    save_screenshot;
}

1;
