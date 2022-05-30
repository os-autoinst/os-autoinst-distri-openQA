use strict;
use base "openQAcoretest";
use testapi;

sub run {
    my ($self) = @_;
    assert_script_run("git clone https://github.com/os-autoinst/openQA.git", timeout => 300);
    assert_script_run("for i in {1..3}; do " . $self->{cre} . " build openQA/container/webui -t openqa_webui && break; done", timeout => 3600);
    assert_script_run("for i in {1..3}; do " . $self->{cre} . " build openQA/container/worker -t openqa_worker && break; done", timeout => 3600);
    assert_script_run("for i in {1..3}; do " . $self->{cre} . " build openQA/container/openqa_data -t openqa_data && break; done", timeout => 3600);
}

1;
