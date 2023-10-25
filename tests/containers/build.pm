use strict;
use base 'openQAcoretest';
use testapi;

sub run {
    assert_script_run('retry -s 30 -r 7 -e -- git clone https://github.com/os-autoinst/openQA.git', timeout => 300);
    assert_script_run("retry -s 30 -r 7 -e -- docker build openQA/container/$_ -t openqa_$_", timeout => 3800) for qw(webui worker);
    assert_script_run('retry -s 30 -r 7 -e -- docker build openQA/container/openqa_data -t openqa_data', timeout => 3800);
}

1;
