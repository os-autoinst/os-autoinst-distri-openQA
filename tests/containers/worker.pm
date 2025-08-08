use base 'openQAcoretest';
use testapi;
use utils;

sub run {
    #my $apikey = '1234567890ABCDEF';
    #my $apikey = '1234567890ABCDEF';
    my $volumes = '-v "/root/data/factory:/data/factory" -v "/root/data/tests:/data/tests" -v "/root/openQA/container/openqa_data/data.template/conf/:/data/conf:ro"';
    script_output(
        "echo  \"\$(cat <<EOF
[openqa_webui]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF

[localhost]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF
EOF
        )\"  > /root/openQA/container/openqa_data/data.template/conf/client.conf"
	);
    script_output(
        "echo  \"\$(cat <<EOF
[global]
BACKEND = qemu
HOST = http://openqa_webui
WORKER_HOSTNAME = openqa_worker
EOF
        )\"  > /root/openQA/container/openqa_data/data.template/conf/workers.ini"
	);
    assert_script_run("docker run -d --network testing $volumes --name openqa_worker openqa_worker");
    my $expected_log = 'Failed to register';
    wait_for_container_log('openqa_worker', 'Failed to register', 'docker');
    record_info("$expected_log", 'https://progress.opensuse.org/issues/186651', result => 'softfail');
    clear_root_console;
}

sub post_run_hook {
  script_run('docker rm -f openqa_worker');
  script_run('docker rm -f openqa_webui');
}

1;
