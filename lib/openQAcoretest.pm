package openQAcoretest;
use base "basetest";
use testapi;


sub get_log {
    my ($cmd, $name) = @_;
    my $ret = script_run "$cmd | tee $name";
    upload_logs($name) if !$ret;
}

sub post_fail_hook {
    send_key 'ctrl-alt-f3';    # root console
    if (check_var('OPENQA_FROM_GIT', 1)) {
        send_key 'ctrl-c';     # Stop current command, if any
        assert_script_run 'cd /root/openQA';
        script_run 'script/client jobs';
        save_screenshot;
        script_run 'which sass';
        get_log 'journalctl --pager-end --no-tail --no-pager -u apache2' => 'openqa_services.log';
        get_log 'cat nohup.out'                                          => 'openqa_nohup_out.txt';
    }
    else {
        script_run 'openqa-client jobs';
        save_screenshot;
        get_log 'journalctl --pager-end --no-tail --no-pager -u apache2 -u openqa-scheduler -u openqa-websockets -u openqa-webui -u openqa-worker@1' => 'openqa_services.log';
        get_log 'cat /var/lib/openqa/pool/1/autoinst-log.txt /var/lib/openqa/testresults/*/*/autoinst-log.txt' => 'autoinst-log.txt';
    }
}

# All steps belonging to core openQA functionality are 'fatal'. by default
sub test_flags {
    return {fatal => 1};
}

1;
