use strict;
use base 'openQAcoretest';
use testapi;
use utils qw(clear_root_console);

sub run {
    assert_script_run 'systemctl status --no-pager openqa-worker@1 | grep --color -z "active (running)"';
    save_screenshot;
    clear_root_console;
}

1;
