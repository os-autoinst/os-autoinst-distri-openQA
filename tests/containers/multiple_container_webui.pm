use Mojo::Base qw(openQAcoretest);
use testapi;
use utils;

sub test_component {
   my ($self, $name, $port, $volumes) = @_;
   assert_script_run($self->{cre} . " run --rm -d --network testing -e MODE=$name -e MOJO_LISTEN=http://0.0.0.0:$port $volumes -p $port:$port --name $name openqa_webui");
   wait_for_container_log($name, "Listening");
   assert_script_run($self->{cre} . " logs $name");
   assert_script_run($self->{cre} . " exec $name curl localhost:$port >/dev/null");
   record_info("$name working");
}

sub run {
   my ($self) = @_;
   my $volumes = '-v "/root/data/factory:/data/factory" -v "/root/data/tests:/data/tests" -v "/root/openQA/container/webui/conf:/data/conf:ro"';

   $self->test_component("webui", 9526, $volumes);
   $self->test_component("websockets", 9527, $volumes);
   $self->test_component("livehandler", 9528, $volumes);
   $self->test_component("scheduler", 9529, $volumes);

   assert_script_run($self->{cre} . " run -d --network testing -e MODE=gru $volumes --name gru openqa_webui");
   wait_for_container_log("gru", "started");

   assert_script_run($self->{cre} . ' rmi -f gru livehandler scheduler websockets');
}

1;
