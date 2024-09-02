use Mojo::Base 'openQAcoretest', -signatures;
use testapi;
use utils qw(install_packages);

sub run {
    # Make sure AppArmor is installed and enabled
    install_packages('-t pattern apparmor');
    assert_script_run('systemctl enable --now apparmor');
    assert_script_run('aa-enabled');
    # Reload AppArmor to enforce newly installed profiles
    assert_script_run('systemctl reload apparmor');
    # Restart running services to apply loaded profiles
    assert_script_run('systemctl try-restart openqa-*', timeout => 300);
    assert_script_run('aa-status --filter.profiles="usr.share.openqa.*"');
}

1;
