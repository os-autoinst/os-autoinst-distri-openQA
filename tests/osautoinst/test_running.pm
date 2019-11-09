use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_script_run 'command -v ack >/dev/null || zypper --no-refresh -n in ack';
    assert_script_run 'ret=false; for i in {1..5} ; do openqa-client jobs state=running | ack --passthru --color running && ret=true && break ; sleep 30 ; done ; [ "$ret" = "true" ]', 300;
    save_screenshot;
    type_string "clear\n";
}

sub post_fail_hook {
    my ($self) = @_;
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
