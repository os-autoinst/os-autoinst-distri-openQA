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
    type_string "1\n";
    wait_still_screen(2);
    type_string "PS1='# '\n";
    wait_still_screen(1);
    validate_script_output 'systemctl status openqa-worker@1', sub { m/\Qactive (running)\E/ };
    save_screenshot;
    type_string "clear\n";
}

1;
