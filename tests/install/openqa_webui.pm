use Mojo::Base 'openQAcoretest';
use testapi;
use utils;


sub install_from_repos {
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
    my $proxy_pkg = (check_var('OPENQA_WEB_PROXY', 'nginx')) ? 'nginx' : '';
    assert_script_run('retry -e -s 30 -- sh -c "zypper -n --gpg-auto-import-keys ref && zypper --no-cd -n in openQA-local-db '.$proxy_pkg.'"', 600);
    my $proxy_args = '';
    if (my $proxy = get_var('OPENQA_WEB_PROXY')) { $proxy_args = "--proxy=$proxy" }
    assert_script_run "/usr/share/openqa/script/configure-web-proxy $proxy_args";
    if (check_var('OPENQA_WEB_PROXY', 'nginx')) {
        assert_script_run 'systemctl disable --now apache2';
        assert_script_run 'systemctl restart nginx';
    }
    else {
        assert_script_run '/usr/share/openqa/script/configure-web-proxy';
        assert_script_run 'systemctl restart apache2';
    }
    assert_script_run($_) foreach (split /\n/, <<~'EOF');
    sed -i -e 's/#.*method.*OpenID.*$/&\nmethod = Fake/' /etc/openqa/openqa.ini
    systemctl enable --now openqa-webui
    systemctl status --no-pager openqa-webui
    systemctl enable --now openqa-scheduler
    systemctl status --no-pager openqa-scheduler
    EOF
}

sub install_from_git {
    assert_script_run($_, 600) foreach (split /\n/, <<~'EOF');
    retry -e -s 30 -- zypper -n in -C 'rubygem(sass)' git-core perl-App-cpanminus perl-Module-CPANfile perl-YAML-LibYAML postgresql-server apache2 npm
    systemctl start postgresql || systemctl status --no-pager postgresql
    su - postgres -c 'createuser root'
    su - postgres -c 'createdb -O root openqa'
    retry -e -s 30 -r 7 -- git clone https://github.com/os-autoinst/openQA.git
    cd openQA
    pkgs=$(for p in $(cpanfile-dump); do echo -n "perl($p) "; done); retry -e -s 30 -- zypper -n in -C $pkgs
    cpanm -nq --installdeps .
    npm install
    for i in headers proxy proxy_http proxy_wstunnel rewrite ; do a2enmod $i ; done
    cp etc/apache2/vhosts.d/openqa-common.inc /etc/apache2/vhosts.d/
    sed "s/#ServerName.*$/ServerName $(hostname)/" etc/apache2/vhosts.d/openqa.conf.template > /etc/apache2/vhosts.d/openqa.conf
    systemctl restart apache2 || systemctl status --no-pager apache2
    mkdir -p /var/lib/openqa/db
    EOF
    script_run('env OPENQA_CONFIG=etc/openqa nohup script/openqa daemon &', 0);
    diag('Wait until the server is responsive');
    assert_script_run('while ! [ -f nohup.out ]; do sleep 1 ; done && grep -qP "Listening at.*(127.0.0.1|localhost)" <(tail -f -n0 nohup.out) ', 600);
}

sub install_containers {
    assert_script_run('retry -s 30 -- zypper -n in docker git', timeout => 600);
    assert_script_run('systemctl start docker');
}

sub install_from_bootstrap {
    assert_script_run('zypper --no-cd -n in openQA-bootstrap');
    assert_script_run('skip_suse_specifics=1 skip_suse_tests=1 /usr/share/openqa/script/openqa-bootstrap', timeout => 1200);
}

sub run {
    switch_to_root_console;
    assert_screen 'inst-console';
    type_string "root\n";
    assert_screen 'password-prompt';
    type_password;
    send_key 'ret';
    wait_still_screen(2);
    disable_packagekit;
    assert_script_run('for i in {1..7}; do zypper --no-cd -n in retry && break; sleep $((i**2*20)); done');
    if (get_var('OPENQA_FROM_GIT')) {
        if (get_var('OPENQA_CONTAINERS')) {
            install_containers;
        }
        else {
            install_from_git;
        }
    }
    elsif (get_var('OPENQA_FROM_BOOTSTRAP')) {
        install_from_bootstrap;
    }
    else {
        install_from_repos;
    }
    save_screenshot;
    clear_root_console;
}

1;
