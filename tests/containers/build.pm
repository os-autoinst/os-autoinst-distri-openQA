use strict;
use base "openQAcoretest";
use testapi;

sub run {
    my ($self) = @_;
    assert_script_run("git clone https://github.com/os-autoinst/openQA.git", timeout => 300);
    assert_script_run("docker build openQA/container/webui -t openqa_webui", timeout => 600);
    assert_script_run("docker build openQA/container/worker -t openqa_worker", timeout => 600);
    assert_script_run("docker build openQA/container/openqa_data -t openqa_data", timeout => 600);
}

1;
