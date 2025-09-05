use Mojo::Base 'openQAcoretest', -signatures;
use testapi;
use utils;

sub run ($self) {
    my $api_query = get_var('FULL_MM_TEST') ? 'test=ping_client' : 'state=running state=done';
    my $success = get_var('FULL_MM_TEST') ? 'passed' : 'passed\|running';
    assert_script_run qq{retry -s 15 -r 60 -- sh -c '
        r=`openqa-cli api jobs $api_query | tee /dev/fd/2 |
        jq -r ".jobs | max_by(.id) | if .result != \\"none\\" then .result else .state end"`;
        echo \$r | grep -q "incomplete\\|failed" && killall retry;
        echo \$r | grep -q "$success"'}, timeout => 930;
    if (get_var('FULL_MM_TEST')) {
        # we can't upload logs if the multimachine OVS bridge in the SUT has the same IP as the openQA-worker host
        script_run 'ip a del 10.0.2.2/15 dev br1'; # This may fail in case this IP is not actually set on the bridge
        $self->upload_openqa_logs;
    }
    save_screenshot;
    assert_script_run q{retry -s 5 -r 3 -- sh -c 'test -f /var/lib/openqa/share/tests/*/.git/config'}, timeout => 20,
        fail_message => 'the test distribution should be checked out by openQA automatically' unless get_var('OPENQA_FROM_GIT');
    clear_root_console;
}

sub post_fail_hook ($self) {
    $self->SUPER::post_fail_hook;
    script_run 'lsmod | grep kvm';
    save_screenshot;
    get_log('grep --color -z -E "(vmx|svm)" /proc/cpuinfo' => 'cpuinfo.txt');
    assert_script_run 'grep --color -z -E "(vmx|svm)" /proc/cpuinfo', fail_message => 'Machine does not support nested virtualization, please enable in worker host';
}

sub test_flags {
    # continue with other tests as we could use their information for
    # debugging in case of failures.
    return {important => 1};
}

1;
