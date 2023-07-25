package openQAcoretest;
use Mojo::Base 'basetest', -signatures;
use testapi;
use utils qw(switch_to_root_console);


sub get_log ($cmd, $name) {
    my $ret = script_run "$cmd | tee $name";
    upload_logs($name) unless $ret;
}

sub post_fail_hook {
    switch_to_root_console;
    if (get_var('OPENQA_FROM_GIT')) {
        send_key 'ctrl-c';     # Stop current command, if any
        assert_script_run 'cd /root/openQA';
        enter_cmd 'script/openqa-cli api jobs';
        save_screenshot;
        enter_cmd 'which sass';
        get_log 'journalctl --pager-end --no-tail --no-pager -u apache2 -u nginx' => 'openqa_services.log';
        get_log 'cat nohup.out'                                                   => 'openqa_nohup_out.txt';
    }
    else {
        enter_cmd 'openqa-cli api jobs';
        save_screenshot;
        get_log 'journalctl --pager-end --no-tail --no-pager -u apache2 -u nginx -u openqa-scheduler -u openqa-websockets -u openqa-webui -u openqa-worker@1' => 'openqa_services.log';
        get_log 'cat /var/lib/openqa/pool/1/autoinst-log.txt /var/lib/openqa/testresults/*/*/autoinst-log.txt' => 'autoinst-log.txt';
    }
}

# All steps belonging to core openQA functionality are 'fatal'. by default
sub test_flags { {fatal => 1} }

1;
