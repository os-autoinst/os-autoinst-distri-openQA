use Mojo::Base qw(openQAcoretest);
use testapi;
use utils;

sub run {
  my ($self) = @_;
  my $volumes = '-v "/root/data/factory:/data/factory" -v "/root/data/tests:/data/tests" -v "/root/openQA/container/openqa_data/data.template/conf/:/data/conf:ro"';

  assert_script_run("docker run -d --network testing $volumes --name openqa_worker openqa_worker");
  wait_for_container_log("openqa_worker", "API key and secret are needed", "docker");
}

1;

