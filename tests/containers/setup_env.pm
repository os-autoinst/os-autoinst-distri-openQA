use Mojo::Base qw(openQAcoretest);
use testapi;
use utils;

sub run {
   my ($self) = @_;

   assert_script_run("echo unqualified-search-registries = ['registry.opensuse.org'] > /etc/containers/registries.conf");
   assert_script_run("mkdir -p /root/data/factory/{iso,hdd,other} /root/data/tests");
   assert_script_run($self->{cre} . " network create testing");
   assert_script_run($self->{cre} . " run --rm -d --network testing -e POSTGRES_PASSWORD=openqa -e POSTGRES_USER=openqa -e POSTGRES_DB=openqa --network-alias=db --name db docker.io/library/postgres:latest", timeout => 600);
   wait_for_container_log("db", "database system is ready to accept connections");
}

1;
