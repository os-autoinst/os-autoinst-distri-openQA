use Mojo::Base 'openQAcoretest';
use testapi;
use utils qw(login disable_packagekit switch_to_root_console clear_root_console wait_for_desktop);

sub run {
    if (get_required_var('VERSION') =~ /(tw|Tumbleweed)/) {
        login;
        # SELinux: allow web proxy to connect to openQA backend
        assert_script_run('semanage boolean -m -1 httpd_can_network_connect');
    } else {
        record_info "SLE", "Registration";
        type_string "root\n";
        assert_screen 'password-prompt';
        type_password;
        send_key 'ret';
        wait_still_screen(2);
        assert_screen 'root-console';
        my $version=script_output(qq{cat /etc/os-release |grep VERSION_ID | sed 's/VERSION_ID=//'});
        my $arch = get_required_var('ARCH');

        script_run "SUSEConnect -r " . get_required_var('SCC_REGCODE'), 300;
        script_run "SUSEConnect -p sle-module-desktop-applications/$version/$arch", 300;
        script_run "SUSEConnect -p sle-module-development-tools/$version/$arch", 300;
        assert_script_run qq{zypper addrepo "https://download.nvidia.com/suse/sle15sp6" nvidia};
        assert_script_run "zypper --gpg-auto-import-keys ref nvidia";
        script_run "SUSEConnect -p sle-we/$version/$arch -r " . get_required_var('SCC_REGCODE_WE'), 300;
        script_run "SUSEConnect -p PackageHub/$version/$arch", 300;

        assert_script_run "zypper -n in lightdm apache2 google-droid-fonts qemu-kvm qemu-img", 500;
        assert_script_run "zypper -n in --recommends -t pattern base x11 gnome", 1000;
        assert_script_run "systemctl set-default graphical.target";
        assert_script_run qq{sed -i 's/DISPLAYMANAGER_AUTOLOGIN=""/DISPLAYMANAGER_AUTOLOGIN=root/' /etc/sysconfig/displaymanager};
        assert_script_run('reboot', 60);
        assert_screen('openqa-desktop', 600);
        send_key 'ret';
        login;
    }
    disable_packagekit;
    assert_script_run('zypper --no-cd -n rm xscreensaver');
    assert_script_run('pkill -f xscreensaver') if (get_required_var('VERSION') =~ /(tw|Tumbleweed)/);
    assert_script_run('for i in {1..7}; do zypper --no-cd -n in retry && break; sleep $((i**2*20)); done');
}

1;
