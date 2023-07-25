use strict;
use base 'openQAcoretest';
use testapi;
use utils qw(switch_to_root_console);

sub run {
    switch_to_root_console;
    enter_cmd 'cd';
    assert_screen 'root-console';
    enter_cmd 'poweroff';
    assert_shutdown 300;
}

sub post_fail_hook {
    # in case plymouth splash screen on shutdown hides some messages
    send_key 'esc' if check_screen 'plymouth';
}

1;
