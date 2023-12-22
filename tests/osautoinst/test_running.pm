use Mojo::Base 'openQAcoretest', -signatures;
use testapi;
use utils;

sub run {
    assert_script_run 'command -v ack >/dev/null || zypper --no-refresh -n in ack';
    assert_script_run q{retry -s 30 -r 5 -- sh -c 'openqa-cli api jobs state=running state=done | ack --passthru --color "running|done"'}, 300;
    save_screenshot;
    clear_root_console;
}

sub post_fail_hook ($self) {
    $self->SUPER::post_fail_hook;
    script_run 'lsmod | grep kvm';
    save_screenshot;
    get_log('grep --color -z -E "(vmx|svm)" /proc/cpuinfo' => 'cpuinfo');
    assert_script_run 'grep --color -z -E "(vmx|svm)" /proc/cpuinfo', fail_message => 'Machine does not support nested virtualization, please enable in worker host';
}

sub test_flags {
    # continue with other tests as we could use their information for
    # debugging in case of failures.
    return {important => 1};
}

1;
