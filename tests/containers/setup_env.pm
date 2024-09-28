use base qw(openQAcoretest);
use testapi;
use utils;

sub run {
   assert_script_run('mkdir -p /root/data/factory/{iso,hdd,other} /root/data/tests');
   assert_script_run('docker network create testing');
   # Temporary fix version https://progress.opensuse.org/issues/167524
   assert_script_run('retry -s 30 -- docker run --rm -d --network testing -e POSTGRES_PASSWORD=openqa -e POSTGRES_USER=openqa -e POSTGRES_DB=openqa --net-alias=db --name db postgres:16', timeout => 600);
   wait_for_container_log('db', 'database system is ready to accept connections', 'docker');
}

1;
