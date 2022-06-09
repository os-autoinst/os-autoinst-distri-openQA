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
    clear_root_console;
    assert_script_run('for i in {1..3}; do zypper -n up --auto-agree-with-licenses && break; done', timeout => 700, fail_message => 'zypper failed to update packages');
    save_screenshot;
}

1;
