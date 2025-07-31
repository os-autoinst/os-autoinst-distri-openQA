use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

sub run {
    return 1 if get_var('OPENQA_FROM_GIT');
    diag('assuming to be in terminal');
    if (get_var('FULL_OPENSUSE_TEST')) {
        diag('initialize working copy of openSUSE tests distribution with correct user');
        assert_script_run("zypper -n in sudo") if (get_required_var('VERSION') =~ /sle/) ;
        assert_script_run('retry -s 30 -- sh -c "username=bernhard email=bernhard@susetest /usr/share/openqa/script/fetchneedles"', 3600);
        save_screenshot;
    }
    # os-autoinst-distri-opensuse is changing quickly so it is likely to have
    # changes within the 10 minutes refresh dead-time applied by default in
    # /etc/zypp/zypp.conf so we need to refresh explicitly with retries in
    # case of problems.
    install_packages('os-autoinst-distri-opensuse-deps');
    clear_root_console;
    # prepare for next test
    enter_cmd 'logout';
    switch_to_x11;
}

1;
