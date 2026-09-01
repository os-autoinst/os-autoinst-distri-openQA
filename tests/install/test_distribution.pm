use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

sub run {
    return 1 if get_var('OPENQA_FROM_GIT');
    diag('assuming to be in terminal');
    if (get_var('FULL_OPENSUSE_TEST')) {
        diag('initialize working copy of openSUSE tests distribution with correct user');
        assert_script_run('retry -s 30 -- sh -c "GIT_ASKPASS= GIT_TERMINAL_PROMPT=false username=bernhard email=bernhard@susetest /usr/share/openqa/script/fetchneedles"', 3600);
        save_screenshot;
    }
    # os-autoinst-distri-opensuse is changing quickly so it is likely to have
    # changed within the 10 minute default refresh timeout of zypper.
    # Therefore we try to refresh explicitly (with retries, in case of problems).
    install_packages('os-autoinst-distri-opensuse-deps');
    # leave a clean root console for the subsequent test module (if it needs x11, it should switch itself)
    clear_root_console;
}

1;
