use Mojo::Base 'openQAcoretest';
use testapi;
use utils qw(login disable_packagekit switch_to_root_console);

sub run {
    login;
    disable_packagekit;
    assert_script_run('for i in {1..7}; do zypper --no-cd -n in retry && break; sleep $((i**2*20)); done');
    assert_script_run('zypper --no-cd -n rm xscreensaver');
    assert_script_run('pkill -f xscreensaver');
}

1;
