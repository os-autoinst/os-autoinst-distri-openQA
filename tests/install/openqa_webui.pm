use Mojo::Base 'openQAcoretest', -signatures;
use testapi;
use utils qw(install_packages clear_root_console get_log);


sub add_repo {
    die 'Needs implementation for other versions' unless get_required_var('VERSION') =~ /(tw|Tumbleweed)/;
    my %repo_suffix = (
        x86_64  => 'Tumbleweed',
        aarch64 => 'Factory_ARM',
        ppc64le => 'Factory_PowerPC'
    );
    my $repo = 'openSUSE_' . $repo_suffix{get_required_var('ARCH')};
    my $project = get_var('OPENQA_OBS_PROJECT', 'devel:openQA');

    # Avoid using the redirector service to cope with transient repo content
    my $repo_url = get_var('OPENQA_REPO_URL', "https://downloadcontent.opensuse.org/repositories/$project/$repo");
    assert_script_run("zypper -n ar -p 95 -f '$repo_url' openQA");
    assert_script_run('retry -e -s 30 -r 7 -- zypper -n --gpg-auto-import-keys ref', timeout => 4000);
}

sub install_from_pkgs {
    diag('following https://github.com/os-autoinst/openQA/blob/master/docs/Installing.asciidoc');
    my $proxy_pkg = (check_var('OPENQA_WEB_PROXY', 'nginx')) ? 'nginx' : '';
    install_packages("openQA-local-db $proxy_pkg");
    my $proxy_args = '';
    if (my $proxy = get_var('OPENQA_WEB_PROXY')) { $proxy_args = "--proxy=$proxy" }
    assert_script_run "/usr/share/openqa/script/configure-web-proxy $proxy_args";
    if (check_var('OPENQA_WEB_PROXY', 'nginx')) {
        assert_script_run 'systemctl disable --now apache2';
        assert_script_run 'systemctl enable nginx';
        assert_script_run 'systemctl restart nginx';
    }
    else {
        assert_script_run 'systemctl enable apache2';
        assert_script_run 'systemctl restart apache2';
    }
    assert_script_run($_) foreach (split /\n/, <<~'EOF');
    if [ -e /etc/openqa/openqa.ini ]; then sed -i -e 's/#.*method.*OpenID.*$/&\nmethod = Fake/' /etc/openqa/openqa.ini; else echo -e "[auth]\nmethod = Fake" > /etc/openqa/openqa.ini.d/auth.ini; fi
    systemctl enable --now openqa-webui
    systemctl status --no-pager openqa-webui
    systemctl enable --now openqa-scheduler
    systemctl status --no-pager openqa-scheduler
    EOF
}

sub install_from_git {
    install_packages(q/'rubygem(sass)' git-core perl-App-cpanminus perl-Module-CPANfile perl-YAML-LibYAML postgresql-server apache2 npm/);
    # The maximum of the retry is 3810 seconds
    assert_script_run('retry -e -s 30 -r 7 -- git clone https://github.com/os-autoinst/openQA.git', timeout => 4000);
    assert_script_run($_, 600) foreach (split /\n/, <<~'EOF');
    systemctl start postgresql || systemctl status --no-pager postgresql
    su - postgres -c 'createuser root'
    su - postgres -c 'createdb -O root openqa'
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

    # Temporary patch to Mojolicious::Plugin::AssetPack::Pipe::Sass
    my $sass = script_output 'perldoc -l Mojolicious::Plugin::AssetPack::Pipe::Sass';
    assert_script_run q{perl -pi -wE 's/\Q = (qw(sass -s)/ = (qw(sass -s --trace)/' } . $sass;
    assert_script_run qq{grep "sass -s" $sass};

    script_run('env OPENQA_CONFIG=etc/openqa nohup script/openqa daemon &', 0);
    diag('Wait until the server is responsive');
    assert_script_run('grep -qP "Listening at.*(127.0.0.1|localhost)" <(tail -F nohup.out) ', 600);

    # Always upload log file always to be able to compare to failing tests
    upload_logs('nohup.out', log_name => 'openqa_nohup_out.txt');
}

sub install_containers {
    install_packages('docker git');
    assert_script_run('systemctl start docker');
}

sub install_from_bootstrap {
    install_packages('openQA-bootstrap');
    assert_script_run('skip_suse_specifics=1 skip_suse_tests=1 /usr/share/openqa/script/openqa-bootstrap', timeout => 1200);
}

sub run {
    add_repo if get_var('ADD_OPENQA_REPO', !get_var('OPENQA_FROM_GIT'));
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
        install_from_pkgs;
    }
    unless (get_var('OPENQA_CONTAINERS')) {
        # Verify that the web UI is available after installation
        assert_script_run('curl --fail-with-body http://localhost/login');
    }
    save_screenshot;
    clear_root_console;
}

sub post_fail_hook ($self) {
    get_log 'tail -n 50000 /var/log/zypper.log' => 'zypper.log.txt';
    get_log 'ls -lRa /var/cache/zypp/raw/' => 'repodata.log.txt';
    assert_script_run('zypper -n --gpg-auto-import-keys ref', timeout => 600);
    get_log 'tail -n 800 /var/log/zypper.log' => 'zypper1.log.txt';
    get_log 'ls -lRa /var/cache/zypp/raw/' => 'repodata1.log.txt';

    $self->SUPER::post_fail_hook;
}

1;
