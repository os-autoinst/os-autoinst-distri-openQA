use Mojo::Base 'openQAcoretest';
use testapi;
use utils qw(login disable_packagekit switch_to_root_console);

sub run {
    login;

    # SELinux: allow web proxy to connect to openQA backend
    assert_script_run('semanage boolean -m -1 httpd_can_network_connect');

    disable_packagekit;
    # Avoid install_packages which relies on retry being installed
    assert_script_run('for i in {1..7}; do zypper -n --gpg-auto-import-keys ref && zypper --no-cd -n in retry && break; sleep $((i**2*20)); done');
    assert_script_run('zypper --no-cd -n rm xscreensaver');
    assert_script_run('pkill -f xscreensaver');
}

1;
