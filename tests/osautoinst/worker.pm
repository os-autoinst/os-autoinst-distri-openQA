use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_screen 'openqa-desktop', 500;
    send_key 'ctrl-alt-f2';
    assert_screen 'inst-console';
    type_string "root\n";
    assert_screen 'password-prompt', 10;
    type_string "1\n";
    sleep 3;
    type_string "PS1=\$\n";
    sleep 1;
    validate_script_output 'systemctl status openqa-worker@1', sub { m/\Qactive (running)\E/ };
    save_screenshot;
    send_key 'ctrl-l';
}

1;
