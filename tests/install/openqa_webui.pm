use strict;
use base "openQAcoretest";
use testapi;
use utils;


sub install_from_repos {
    diag('following https://github.com/os-autoinst/openQA/blob/master/docs/Installing.asciidoc');
    my $add_repo;
    if (get_required_var('VERSION') =~ /(tw|Tumbleweed)/) {
        if (check_var('ARCH', 'ppc64le')) {
            $add_repo = <<'EOF';
zypper --non-interactive ar -f obs://devel:openQA/openSUSE_Factory_PowerPC openQA
EOF
        }
        else {
            $add_repo = <<'EOF';
zypper --non-interactive ar -f obs://devel:openQA/openSUSE_Tumbleweed openQA
EOF
        }
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
}

sub install_from_git {
    my $configure = <<'EOF';
echo "I am not sure about the next line but Santi told me - imagine a venezualean accent - you want this"
zypper --non-interactive in -t pattern devel_basis devel_ruby devel_perl devel_python devel_C_C++
zypper --non-interactive in git-core
git clone https://github.com/os-autoinst/openQA.git
curl -L https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm | perl - App::cpanminus
cpanm local::lib
echo 'eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"' >> ~/.bashrc
. ~/.bashrc
gem install sass
ln -sf /usr/bin/sass.ruby* /usr/bin/sass
ln -sf /usr/bin/scss.ruby* /usr/bin/scss
cd openQA
cpanm -nq --installdeps .
zypper --non-interactive in apache2
for i in headers proxy proxy_http proxy_wstunnel ; do a2enmod $i ; done
cp etc/apache2/vhosts.d/openqa-common.inc /etc/apache2/vhosts.d/
sed "s/#ServerName.*$/ServerName $(hostname)/" etc/apache2/vhosts.d/openqa.conf.template > /etc/apache2/vhosts.d/openqa.conf
systemctl restart apache2 || systemctl status --no-pager apache2
install -D -m 640 /dev/null /var/lib/openqa/db/db.sqlite
EOF
    assert_script_run($_, 600) foreach (split /\n/, $configure);
    script_run('env OPENQA_CONFIG=etc/openqa nohup script/openqa daemon &', 0);
    diag('Wait until the server is responsive');
    assert_script_run('grep -q "Listening at.*localhost" <(tail -f -n0 nohup.out)', 600);
}

sub run {
    send_key "ctrl-alt-f2";
    assert_screen "inst-console";
    type_string "root\n";
    assert_screen "password-prompt";
    type_string $testapi::password . "\n";
    wait_still_screen(2);
    diag('Ensure packagekit is not interfering with zypper calls');
    script_run('systemctl stop packagekit.service; systemctl mask packagekit.service');
    if (check_var('OPENQA_FROM_GIT', 1)) {
        install_from_git;
    }
    else {
        install_from_repos;
    }
    save_screenshot;
    type_string "clear\n";
}

1;
