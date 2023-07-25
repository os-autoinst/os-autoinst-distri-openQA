use strict;
use base 'openQAcoretest';
use testapi;
use utils;

sub run {
    wait_for_desktop;
    switch_to_root_console;
    assert_screen 'inst-console';
    type_string "root\n";
    assert_screen 'password-prompt';
    type_string "1\n";
    wait_still_screen(2);
    disable_packagekit;
    save_screenshot;
    clear_root_console;
    assert_script_run('retry -s 30 -- zypper -n up --auto-agree-with-licenses', timeout => 700, fail_message => 'zypper failed to update packages');
    save_screenshot;
}

1;
