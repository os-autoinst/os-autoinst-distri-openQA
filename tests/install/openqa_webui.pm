use strict;
use base "openQAcoretest";
use testapi;
use utils;


sub run {
    send_key "ctrl-alt-f2";
    assert_screen "inst-console";
    type_string "root\n";
    assert_screen "password-prompt";
    type_string $testapi::password . "\n";
    wait_still_screen(2);
    type_string "PS1='# '\n";
    wait_still_screen(1);
    diag('following https://github.com/os-autoinst/openQA/blob/master/docs/Installing.asciidoc');
    die "Needs implementation for other versions" unless check_var('VERSION', 'Tumbleweed');
    my $install = <<'EOF';
zypper --non-interactive ar -f obs://devel:openQA/openSUSE_Factory openQA
zypper --non-interactive --gpg-auto-import-keys in openQA openQA-worker
for i in headers proxy proxy_http proxy_wstunnel ; do a2enmod $i ; done
sed -i -e 's/^.*httpsonly.*$/httpsonly = 0/g' /etc/openqa/openqa.ini
sed -i -e 's/#.*method.*OpenID.*$/&\nmethod = Fake/' /etc/openqa/openqa.ini
sed "s/#ServerName.*$/ServerName $(hostname)/" /etc/apache2/vhosts.d/openqa.conf.template > /etc/apache2/vhosts.d/openqa.conf
systemctl restart apache2
systemctl start openqa-webui
systemctl status openqa-webui
systemctl enable openqa-webui
EOF
    assert_script_run($_, 600) foreach (split /\n/, $install);
    save_screenshot;
    type_string "clear\n";
}

1;
