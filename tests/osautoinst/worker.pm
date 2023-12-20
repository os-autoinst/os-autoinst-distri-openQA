use Mojo::Base 'openQAcoretest';
use testapi;
use utils qw(wait_for_desktop switch_to_root_console clear_root_console);

sub run {
    wait_for_desktop;
    switch_to_root_console;
    assert_screen 'inst-console';
    type_string "root\n";
    assert_screen 'password-prompt';
    type_password;
    send_key 'ret';
    wait_still_screen(2);
    assert_script_run 'systemctl status --no-pager openqa-worker@1 | grep --color -z "active (running)"';
    script_run('dmesg -D'); # workaround for bsc#1217397
    save_screenshot;
    clear_root_console;
}

1;
