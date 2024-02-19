use Mojo::Base 'openQAcoretest';
use testapi;
use utils qw(disable_packagekit switch_to_root_console);

sub login {
    switch_to_root_console;
    assert_screen 'inst-console';
    type_string "root\n";
    assert_screen 'password-prompt';
    type_password;
    send_key 'ret';
    wait_still_screen(2);
}

sub run {
    login;

    disable_packagekit;
    assert_script_run('for i in {1..7}; do zypper --no-cd -n in retry && break; sleep $((i**2*20)); done');
    assert_script_run('zypper --no-cd -n rm xscreensaver');
    assert_script_run('pkill -f xscreensaver');
}

1;
