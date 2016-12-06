use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_script_run 'openqa-client jobs state=running | grep --color -z running';
    save_screenshot;
    type_string "clear\n";
}

sub get_log {
    my ($cmd, $name) = @_;
    my $ret = script_run "$cmd | tee $name";
    upload_logs $name if $ret;
}

sub post_fail_hook {
    script_run 'openqa-client jobs';
    save_screenshot;
    get_log 'journalctl --pager-end --no-tail --no-pager -u apache2 -u openqa-scheduler -u openqa-websockets -u openqa-webui -u openqa-worker@1' => 'openqa_services.log';
    get_log 'cat /var/lib/openqa/pool/1/autoinst-log.txt /var/lib/openqa/testresults/*/*/autoinst-log.txt' => 'autoinst-log.txt';
    script_run 'lsmod | grep kvm';
    save_screenshot;
    get_log 'grep --color -z -E "(vmx|svm)" /proc/cpuinfo' => 'cpuinfo';
    assert_script_run 'grep --color -z -E "(vmx|svm)" /proc/cpuinfo', fail_message => 'Machine does not support nested virtualization, please enable in worker host';
}

sub test_flags {
    # continue with other tests as we could use their information for
    # debugging in case of failures.
    return { important => 1 };
}

1;
