use base 'openQAcoretest';
use testapi;
use utils;

sub run {
    my $confdir = '/tmp/openqa_worker_conf';
    assert_script_run("mkdir -p $confdir");
    assert_script_run(
        "echo  \"\$(cat <<EOF
[openqa_webui]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF
EOF
)\" > $confdir/client.conf");

    assert_script_run(
        "echo  \"\$(cat <<EOF
[global]
BACKEND = qemu
HOST = openqa_webui
WORKER_HOSTNAME = openqa_worker
EOF
)\" > $confdir/workers.ini");
    my $volumes = qq{-v "/root/data/factory:/data/factory" -v "/root/data/tests:/data/tests" -v "$confdir:/data/conf:ro"};
    assert_script_run('curl -v http://localhost/login');
    assert_script_run(qq{docker run -d --network testing $volumes --hostname openqa_worker --name openqa_worker openqa_worker});
    wait_for_container_log('openqa_worker', 'Registered and connected', 'docker');
    clear_root_console;
}

sub post_run_hook {
  script_run('docker rm -f openqa_worker');
  script_run('docker rm -f openqa_webui');
}

1;
