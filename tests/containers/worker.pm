use base 'openQAcoretest';
use testapi;
use utils;

sub run {
  my %confs = (
      client_conf => {
          path => 'conf/client.conf',
          output => ''
      },
      worker_ini => {
          path => 'conf/workers.ini',
          output => ''
      }
);
  my $volumes = '-v "/root/data/factory:/data/factory" -v "/root/data/tests:/data/tests" -v "/root/openQA/container/openqa_data/data.template/conf/:/data/conf:ro"';
  my $data_container_path = '/root/openQA/container/openqa_data/data.template/';
  $confs{client_conf}{output} = script_output("cat $data_container_path$confs{client_conf}{path}");
  $confs{worker_ini}{output} = script_output("cat $data_container_path$confs{worker_ini}{path}");

  assert_script_run("docker run -d --network testing $volumes --name openqa_worker openqa_worker");
  wait_for_container_log('openqa_worker', 'API key and secret are needed', 'docker');
  for my $f (keys %confs) {
      validate_script_output("docker run -it --log-driver=none --entrypoint=cat --net=host $volumes --name openqa_worker_$f openqa_worker /data/" . $confs{$f}{path},
                             sub {
                                 $_ =~ s/\r//g;
                                 $confs{$f}{output} =~ s/\r//g; # $client_conf
                                 $_ =~ m/\Q$confs{$f}{output}\E/;
                             }, title => "$f check");
  }
  clear_root_console;
}

1;
