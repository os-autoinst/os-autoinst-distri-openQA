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
    type_string "clear\n";
    # prepare for next test
    type_string "logout\n";
    send_key 'ctrl-alt-f7';
}

1;

