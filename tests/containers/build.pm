use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub run {
    my ($self) = @_;
    assert_script_run("git clone https://github.com/os-autoinst/openQA.git", timeout => 300);
    script_retry('docker build openQA/container/webui -t openqa_webui', retry => 3, delay => 60, timeout => 3600);
    script_retry('docker build openQA/container/worker -t openqa_worker', retry => 3, delay => 60, timeout => 3600);
    script_retry('docker build openQA/container/openqa_data -t openqa_data', retry => 3, delay => 60, timeout => 3600);
}

1;
