use Mojo::Base qw(openQAcoretest), -signatures;
use testapi;
use utils;

sub test_component ($name, $port, $volumes) {
   assert_script_run("docker run --rm -d --network testing -e MODE=$name -e MOJO_LISTEN=http://0.0.0.0:$port $volumes -p $port:$port --name $name openqa_webui");
   wait_for_container_log($name, 'Listening', 'docker');
   assert_script_run("docker logs $name");
   assert_script_run("docker exec $name curl localhost:$port >/dev/null");
   record_info("$name working");
}

sub run {
   my $volumes = '-v "/root/data/factory:/data/factory" -v "/root/data/tests:/data/tests" -v "/root/openQA/container/webui/conf:/data/conf:ro"';

   test_component('webui', 9526, $volumes);
   test_component('websockets', 9527, $volumes);
   test_component('livehandler', 9528, $volumes);
   test_component('scheduler', 9529, $volumes);

   assert_script_run("docker run -d --network testing -e MODE=gru $volumes --name gru openqa_webui");
   wait_for_container_log('gru', 'started', 'docker');

   assert_script_run('docker rm -f webui');
   assert_script_run('docker rm -f websockets');
   assert_script_run('docker rm -f livehandler');
   assert_script_run('docker rm -f scheduler');
   assert_script_run('docker rm -f gru');
}

1;
