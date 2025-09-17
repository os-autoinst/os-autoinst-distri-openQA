use Mojo::Base qw(openQAcoretest);
use testapi;
use utils;

sub run {
  script_run(
        "echo  \"\$(cat <<EOF
[localhost]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF

[scheduler]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF

[websockets]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF

[openqa_webui]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF
EOF
)\" > /root/openQA/container/webui/conf/client.conf");
  script_run(
        "echo  \"\$(cat <<EOF
[global]
# change to the URL the web UI will be available under so redirection for
# authentication works
base_url = http://openqa_webui

[auth]
method = Fake

[logging]
level = debug

[openid]
httpsonly = 0
EOF
)\" > /root/openQA/container/webui/conf/openqa.ini");

  my $volumes = '-v "/root/data/factory:/data/factory" -v "/root/data/tests:/data/tests" -v "/root/openQA/container/webui/conf:/data/conf:ro"';
  my $certificates = '-v "/root/server.crt:/etc/apache2/ssl.crt/server.crt" -v "/root/server.crt:/etc/apache2/ssl.crt/ca.crt" -v "/root/server.key:/etc/apache2/ssl.key/server.key"';

  assert_script_run("openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -subj '/CN=www.mydom.com/O=My Company Name LTD./C=DE' -out server.crt -keyout server.key");

  assert_script_run("docker run -d --network testing $volumes $certificates -p 80:80 --hostname openqa_webui --name openqa_webui openqa_webui");
  wait_for_container_log('openqa_webui', 'Web application available at', 'docker');

  assert_script_run('curl http://localhost');
  assert_script_run(qq{docker exec openqa_webui sed -i "s/#ServerName your.server.name/ServerName openqa_webui/" /etc/apache2/vhosts.d/openqa.conf});
  assert_script_run(qq{docker exec openqa_webui sh -c 'echo "ServerName openqa_webui" >> /etc/apache2/httpd.conf'});
  assert_script_run(qq{docker exec openqa_webui apache2ctl restart});
}

sub post_fail_hook {
  script_run('docker logs openqa_webui');
  script_run('docker rm -f openqa_webui');
}

1;
