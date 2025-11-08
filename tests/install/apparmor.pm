use Mojo::Base 'openQAcoretest', -signatures;
use testapi;
use utils qw(login install_packages wait_for_desktop);

sub enable_apparmor {
    assert_script_run('sed -i -e "s/^..*$/& security=apparmor apparmor=1/" /etc/kernel/cmdline');
    assert_script_run('update-bootloader');
    assert_script_run('systemctl reboot');
    wait_for_desktop;
    login;
    # Fix worker after reboot
    assert_script_run('curl http://localhost/login');
    assert_script_run('systemctl restart openqa-worker@1');
}

sub run {
    # Make sure AppArmor is installed and enabled
    install_packages('-t pattern apparmor');
    assert_script_run('systemctl enable --now apparmor');
    enable_apparmor if script_output('aa-enabled', proceed_on_failure => 1) =~ m/disabled at boot/;
    assert_script_run('aa-enabled');
    # Reload AppArmor to enforce newly installed profiles
    assert_script_run('systemctl reload apparmor');
    # Restart running services to apply loaded profiles
    assert_script_run('systemctl try-restart openqa-*', timeout => 300);
    assert_script_run('aa-status --filter.profiles="usr.share.openqa.*"');
}

1;
