use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

sub run {
    diag('worker setup');
    install_packages('openQA-worker', 3800);
    diag('Login once with fake authentication on openqa webUI to actually create preconfigured API keys for worker authentication');
    assert_script_run('curl --fail-with-body http://localhost/login');
    diag('adding temporary, preconfigured API keys to worker config');
    type_string('cat >> /etc/openqa/client.conf <<EOF
[localhost]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF
EOF
');
    if (get_var('FULL_MM_TEST')) {
        # add tap class to worker config
        my $arch = get_required_var('ARCH');
        my $class = "WORKER_CLASS=qemu_$arch,tap";
        assert_script_run sprintf q{if [ -e /etc/openqa/workers.ini ]; then sed -i -e "s/\(\[global\]\)/\1\n%s/" /etc/openqa/workers.ini; else echo -e "[global]\n%s" > /etc/openqa/workers.ini.d/base.ini; fi}, $class, $class;
    }
    if (get_var('FULL_MM_TEST')) {
        assert_script_run('os-autoinst-setup-multi-machine', timeout => 120);
        my $systemctl_openvswitch = 'systemctl status --no-pager os-autoinst-openvswitch';
    }
    my $worker_setup = <<'EOF';
$systemctl_openvswitch
systemctl enable --now openqa-worker@1
systemctl status --no-pager openqa-worker@1
EOF
    assert_script_run($_) foreach (split /\n/, $worker_setup);
    assert_script_run "systemctl enable --now openqa-worker@2" if get_var('FULL_MM_TEST');
    save_screenshot;
    clear_root_console;
}

1;
