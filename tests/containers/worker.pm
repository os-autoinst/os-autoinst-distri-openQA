use base 'openQAcoretest';
use testapi;
use utils;

sub run {
    my $volumes = '-v "/root/data/factory:/data/factory" -v "/root/data/tests:/data/tests" -v "/root/openQA/container/openqa_data/data.template/conf/:/data/conf:ro"';
    script_run(
        "echo  \"\$(cat <<EOF
[openqa_webui]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF

[localhost]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF
EOF
)\" > /root/openQA/container/openqa_data/data.template/conf/client.conf");

    script_run(
        "echo  \"\$(cat <<EOF
[global]
BACKEND = qemu
HOST = openqa_webui
WORKER_HOSTNAME = openqa_worker
EOF
)\" > /root/openQA/container/openqa_data/data.template/conf/workers.ini");
    assert_script_run(qq{docker run -d --network testing $volumes --entrypoint sh --hostname openqa_worker --name openqa_worker openqa_worker -c "curl -v http://openqa_webui/login && ./run_openqa_worker.sh"});
    wait_for_container_log('openqa_worker', 'Registered and connected', 'docker');
    clear_root_console;
}

sub post_run_hook {
  script_run('docker rm -f openqa_worker');
  script_run('docker rm -f openqa_webui');
}

1;
