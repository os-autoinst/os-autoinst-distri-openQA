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
    diag('Ensure packagekit is not interfering with zypper calls');
    script_run('systemctl stop packagekit.service; systemctl mask packagekit.service');
    diag('following https://github.com/os-autoinst/openQA/blob/master/docs/Installing.asciidoc');
    my $add_repo;
    if (get_required_var('VERSION') =~ /(tw|Tumbleweed)/) {
        $add_repo = <<'EOF';
zypper --non-interactive ar -f obs://devel:openQA/openSUSE_Tumbleweed openQA
EOF
    }
    elsif (check_var('VERSION', '42.1')) {
        $add_repo = <<'EOF';
zypper ar -f obs://devel:openQA/openSUSE_Leap_42.1 openQA
zypper ar -f obs://devel:openQA:Leap:42.1/openSUSE_Leap_42.1 openQA-perl-modules
EOF
    }
    elsif (check_var('VERSION', 'SLES-12SP1')) {
        $add_repo = <<'EOF';
zypper ar -f http://download.opensuse.org/repositories/devel:/openQA/SLE_12_SP1/devel:openQA.repo
zypper ar -f http://download.opensuse.org/repositories/devel:/openQA:/SLE-12/SLE_12_SP1/devel:openQA:SLE-12.repo
EOF
    }
    else {
        die "Needs implementation for other versions";
    }
    assert_script_run($_) foreach (split /\n/, $add_repo);
    assert_script_run('zypper --no-cd --non-interactive --gpg-auto-import-keys in openQA', 600);
    my $configure = <<'EOF';
for i in headers proxy proxy_http proxy_wstunnel ; do a2enmod $i ; done
sed -i -e 's/^.*httpsonly.*$/httpsonly = 0/g' /etc/openqa/openqa.ini
sed -i -e 's/#.*method.*OpenID.*$/&\nmethod = Fake/' /etc/openqa/openqa.ini
sed "s/#ServerName.*$/ServerName $(hostname)/" /etc/apache2/vhosts.d/openqa.conf.template > /etc/apache2/vhosts.d/openqa.conf
systemctl restart apache2
systemctl start openqa-webui
systemctl status --no-pager openqa-webui
systemctl enable openqa-webui
EOF
    assert_script_run($_) foreach (split /\n/, $configure);
    script_run('systemctl unmask packagekit.service; systemctl start packagekit.service');
    save_screenshot;
    type_string "clear\n";
}

1;
