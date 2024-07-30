package openQAcoretest;
use Mojo::Base 'basetest', -signatures;
use testapi;
use utils qw(switch_to_root_console get_log);


sub post_fail_hook ($self) {
    switch_to_root_console;
    send_key 'ctrl-c';     # Stop current command, if any
    # we can't upload logs if the multimachine OVS bridge in the SUT has the same IP as the openQA-worker host
    script_run 'ip a del 10.0.2.2/15 dev br1'; # This may fail in case this IP is not actually set on the bridge
    if (get_var('OPENQA_FROM_GIT')) {
        assert_script_run 'cd /root/openQA';
        enter_cmd 'script/openqa-cli api jobs';
        save_screenshot;
        enter_cmd 'which sass';
        get_log 'journalctl --pager-end --no-tail --no-pager -u apache2 -u nginx' => 'openqa_services.log.txt';
        get_log 'cat nohup.out'                                                   => 'openqa_nohup_out.txt';
    }
    else {
        enter_cmd 'openqa-cli api jobs';
        save_screenshot;
        get_log 'journalctl --pager-end --no-tail --no-pager -u apache2 -u nginx -u openqa-scheduler -u openqa-websockets -u openqa-webui -u openqa-gru -u openqa-worker@1' => 'openqa_services.log.txt';
        get_log '(cat /var/lib/openqa/pool/1/autoinst-log.txt /var/lib/openqa/testresults/*/*/autoinst-log.txt ||:)' => 'autoinst-log.txt';
    }
}

# All steps belonging to core openQA functionality are 'fatal'. by default
sub test_flags { {fatal => 1} }

1;
