use Mojo::Base 'openQAcoretest', -signatures;
use testapi;

sub run {
    # The maximum of the retry is 3810 seconds
    assert_script_run('retry -s 30 -r 7 -e -- git clone https://github.com/os-autoinst/openQA.git', timeout => 4000);
    assert_script_run("retry -s 30 -r 7 -e -- bash -o pipefail -c 'docker build openQA/container/$_ -t openqa_$_ --progress=plain 2>&1 | tee docker_build.txt'", timeout => 4000) for qw(webui worker);
    assert_script_run("retry -s 30 -r 7 -e -- bash -o pipefail -c 'docker build openQA/container/openqa_data -t openqa_data --progress=plain 2>&1 | tee docker_build.txt'", timeout => 4000);
}

sub post_fail_hook ($self) {
    save_screenshot;
    upload_logs 'docker_build.txt';
    my $log = script_output('cat docker_build.txt');
    record_info('docker build', $log, result => 'fail');
    $self->SUPER::post_fail_hook;
}

1;
