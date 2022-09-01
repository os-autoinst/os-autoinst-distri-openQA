use strict;
use base "openQAcoretest";
use testapi;

sub run {
    my ($self) = @_;
    assert_script_run("git clone https://github.com/os-autoinst/openQA.git", timeout => 300);
    assert_script_run("retry -s 30 -- docker build openQA/container/$_ -t openqa_$_", timeout => 2400) for qw(webui worker);
    assert_script_run('retry -s 30 -- docker build openQA/container/openqa_data -t openqa_datai', timeout => 3600);
}

1;
