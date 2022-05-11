use Mojo::Base qw(openQAcoretest);
use testapi;
use utils;

sub run {
  my ($self) = @_;
  my $volumes = '-v "/root/data/factory:/data/factory" -v "/root/data/tests:/data/tests" -v "/root/openQA/container/webui/conf:/data/conf:ro"';
  my $certificates = '-v "/root/server.crt:/etc/apache2/ssl.crt/server.crt" -v "/root/server.crt:/etc/apache2/ssl.crt/ca.crt" -v "/root/server.key:/etc/apache2/ssl.key/server.key"';

  assert_script_run("openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -subj '/CN=www.mydom.com/O=My Company Name LTD./C=DE' -out server.crt -keyout server.key");

  assert_script_run($self->{cre} . " run -d --network testing $volumes $certificates -p 80:80 --name openqa_webui openqa_webui");
  wait_for_container_log("openqa_webui", "Web application available at");

  assert_script_run("curl http://localhost");
  assert_script_run($self->{cre} . " rm -f openqa_webui");
}

sub post_fail_hook {
  my ($self) = @_;
  script_run($self->{cre} . " logs openqa_webui");
  script_run($self->{cre} . " rm -f openqa_webui");
}

1;
