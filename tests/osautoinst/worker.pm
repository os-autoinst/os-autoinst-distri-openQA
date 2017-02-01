use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub run {
    wait_for_desktop;
    send_key 'ctrl-alt-f2';
    assert_screen 'inst-console';
    type_string "root\n";
    assert_screen 'password-prompt', 10;
    type_string $testapi::password . "\n";
    wait_still_screen(2);
    assert_script_run 'systemctl status --no-pager openqa-worker@1 | grep --color -z "active (running)"';
    save_screenshot;
    type_string "clear\n";
}

1;
