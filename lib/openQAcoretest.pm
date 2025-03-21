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
        $self->upload_openqa_logs;
    }
    get_log 'cat /var/log/audit/audit.log' => 'audit.log.txt';
}

# All steps belonging to core openQA functionality are 'fatal'. by default
sub test_flags { {fatal => 1} }

sub upload_openqa_logs {
    get_log 'ps -ef' => 'running_processes.txt';
    get_log 'journalctl --pager-end --no-tail --no-pager -u apache2 -u nginx -u openqa-scheduler -u openqa-websockets -u openqa-webui -u openqa-gru -u openqa-worker@1' => 'openqa_services.log.txt';
    get_log 'journalctl --pager-end --no-tail --no-pager' => 'journal.log.txt';
    my @logs = split m/\n/, script_output q{find /var/lib/openqa -name autoinst-log.txt};
    @logs and get_log "(cat @logs ||:)" => 'autoinst-log.txt';
    get_log '(find /var/lib/openqa/pool/ /var/lib/openqa/testresults/ ||:)' => 'find.txt';
    # do not assert for tar as it might return 1 due to the -h flag when dereferencing broken symlinks
    script_run q{tar cahvf /tmp/testresults.tar.xz -C /var/lib/openqa/ testresults};
    upload_logs "/tmp/testresults.tar.xz" if (script_run("test -f /tmp/testresults.tar.xz") == 0);
    get_log q|sudo -u geekotest /usr/share/openqa/script/openqa eval -V 'my $jobs = app->minion->jobs; my @r; while (my $j = $jobs->next) { push @r, $j->{result} }; \@r'| => 'openqa_minion_results.txt';
    get_log q{openqa-cli api jobs | jq .} => 'openqa-api-jobs.json';
}

1;
