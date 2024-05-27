use Mojo::Base 'openQAcoretest';
use testapi;

sub run {
    # The maximum of the retry is 3810 seconds
    assert_script_run('retry -s 30 -r 7 -e -- git clone https://github.com/os-autoinst/openQA.git', timeout => 4000);
    assert_script_run("retry -s 30 -r 7 -e -- docker build openQA/container/$_ -t openqa_$_", timeout => 4000) for qw(webui worker);
    assert_script_run('retry -s 30 -r 7 -e -- docker build openQA/container/openqa_data -t openqa_data', timeout => 4000);
}

1;
