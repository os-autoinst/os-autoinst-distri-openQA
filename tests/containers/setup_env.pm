use Mojo::Base qw(openQAcoretest);
use testapi;
use utils;

sub run {
   my ($self) = @_;

   assert_script_run("mkdir -p /root/data/factory/{iso,hdd,other} /root/data/tests");
   assert_script_run("docker network create testing");
   assert_script_run("retry -s 30 -- docker run --rm -d --network testing -e POSTGRES_PASSWORD=openqa -e POSTGRES_USER=openqa -e POSTGRES_DB=openqa --net-alias=db --name db postgres", timeout => 600);
   wait_for_container_log("db", "database system is ready to accept connections", "docker");
}

1;
