use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub run {
    return 1 if check_var('OPENQA_FROM_GIT', 1);
    diag('assuming to be in terminal');
    diag('initialize working copy of openSUSE tests distribution with correct user');
    assert_script_run('username=bernhard email=bernhard@susetest /usr/share/openqa/script/fetchneedles', 3600);
    save_screenshot;
    assert_script_run('zypper -n ref -f',                              60);
    assert_script_run('zypper -n in os-autoinst-distri-opensuse-deps', 600);
    clear_root_console;
    # prepare for next test
    enter_cmd "logout";
    switch_to_x11;
}

1;

