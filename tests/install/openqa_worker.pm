use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

sub run {
    diag('worker setup');
    assert_script_run('retry -e -s 30 -r 7 -- sh -c "zypper -n --gpg-auto-import-keys ref && zypper --no-cd -n in openQA-worker"', 3800);
    diag('Login once with fake authentication on openqa webUI to actually create preconfigured API keys for worker authentication');
    assert_script_run('curl http://localhost/login');
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
        assert_script_run q{sed -i -e "s/\(\[global\]\)/\1\nWORKER_CLASS=qemu_}.$arch.q{,tap/" /etc/openqa/workers.ini};
    }
    assert_script_run('os-autoinst-setup-multi-machine', timeout => 120);
    my $worker_setup = <<'EOF';
systemctl status --no-pager os-autoinst-openvswitch
systemctl enable --now openqa-worker@1
systemctl status --no-pager openqa-worker@1
EOF
    assert_script_run($_) foreach (split /\n/, $worker_setup);
    assert_script_run "systemctl enable --now openqa-worker@2" if get_var('FULL_MM_TEST');
    save_screenshot;
    clear_root_console;
}

1;
