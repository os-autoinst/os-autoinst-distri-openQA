use strict;
use base 'openQAcoretest';
use testapi;
use utils qw(wait_for_desktop switch_to_root_console clear_root_console);

sub run {
    switch_to_root_console;
    assert_script_run 'systemctl status --no-pager openqa-worker@1 | grep --color -z "active (running)"';
    save_screenshot;
    clear_root_console;
}

1;
