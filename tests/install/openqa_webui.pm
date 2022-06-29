use strict;
use base "openQAcoretest";
use testapi;
use utils;


sub install_from_repos {
    assert_script_run('retry -s 30 -- zypper --no-cd -n --gpg-auto-import-keys in openQA-local-db', 600);
    diag('following https://github.com/os-autoinst/openQA/blob/master/docs/Installing.asciidoc');
    my $add_repo;
    die 'Needs implementation for other versions' unless get_required_var('VERSION') =~ /(tw|Tumbleweed)/;
    my %repo_suffix = (
        x86_64  => 'Tumbleweed',
        aarch64 => 'Factory_ARM',
        ppc64le => 'Factory_PowerPC'
    );
    my $repo = 'openSUSE_' . $repo_suffix{get_required_var('ARCH')};
    $add_repo = "zypper -n ar -p 95 -f obs://devel:openQA/$repo openQA";
    assert_script_run($_) foreach (split /\n/, $add_repo);
    assert_script_run('retry -s 30 -- zypper --no-cd -n --gpg-auto-import-keys in openQA-local-db', 600);
    my $configure = <<'EOF';
/usr/share/openqa/script/configure-web-proxy
sed -i -e 's/#.*method.*OpenID.*$/&\nmethod = Fake/' /etc/openqa/openqa.ini
systemctl restart apache2
systemctl enable --now openqa-webui
systemctl status --no-pager openqa-webui
systemctl enable --now openqa-scheduler
systemctl status --no-pager openqa-scheduler
EOF
    assert_script_run($_) foreach (split /\n/, $configure);
}

sub install_from_git {
    my $configure = <<'EOF';
retry -s 30 -- zypper -n in -C 'rubygem(sass)' git-core perl-App-cpanminus perl-Module-CPANfile perl-YAML-LibYAML postgresql-server apache2
systemctl start postgresql || systemctl status --no-pager postgresql
su - postgres -c 'createuser root'
su - postgres -c 'createdb -O root openqa'
git clone https://github.com/os-autoinst/openQA.git
cd openQA
pkgs=$(for p in $(cpanfile-dump); do echo -n "perl($p) "; done); retry -s 30 -- zypper -n in -C $pkgs
cpanm -nq --installdeps .
for i in headers proxy proxy_http proxy_wstunnel rewrite ; do a2enmod $i ; done
cp etc/apache2/vhosts.d/openqa-common.inc /etc/apache2/vhosts.d/
sed "s/#ServerName.*$/ServerName $(hostname)/" etc/apache2/vhosts.d/openqa.conf.template > /etc/apache2/vhosts.d/openqa.conf
systemctl restart apache2 || systemctl status --no-pager apache2
mkdir -p /var/lib/openqa/db
EOF
    assert_script_run($_, 600) foreach (split /\n/, $configure);
    script_run('env OPENQA_CONFIG=etc/openqa nohup script/openqa daemon &', 0);
    diag('Wait until the server is responsive');
    assert_script_run('while ! [ -f nohup.out ]; do sleep 1 ; done && grep -qP "Listening at.*(127.0.0.1|localhost)" <(tail -f -n0 nohup.out) ', 600);
}

sub install_containers {
    assert_script_run('retry -s 30 -- zypper -n in docker git', timeout => 600);
    assert_script_run("systemctl start docker");
}

sub run {
    send_key "ctrl-alt-f3";
    assert_screen "inst-console";
    type_string "root\n";
    assert_screen "password-prompt";
    type_string $testapi::password . "\n";
    wait_still_screen(2);
    diag('Ensure packagekit is not interfering with zypper calls');
    assert_script_run('systemctl mask --now packagekit');
    assert_script_run('zypper --no-cd -n in retry');
    if (check_var('OPENQA_FROM_GIT', 1)) {
        if (get_var('OPENQA_CONTAINERS')) {
            install_containers;
        }
        else {
            install_from_git;
        }
    }
    else {
        install_from_repos;
    }
    save_screenshot;
    clear_root_console;
}

1;
