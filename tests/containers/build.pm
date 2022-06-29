use strict;
use base "openQAcoretest";
use testapi;

sub run {
    my ($self) = @_;
    assert_script_run("git clone https://github.com/os-autoinst/openQA.git", timeout => 300);
    assert_script_run('for i in webui worker; do retry -s 30 -- docker build openQA/container/$i -t openqa_$i; done', timeout => 4800);
    assert_script_run('retry -s 30 -- docker build openQA/container/openqa_data -t openqa_datai', timeout => 3600);
}

1;
