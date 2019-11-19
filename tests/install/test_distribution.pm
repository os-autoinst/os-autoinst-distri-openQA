use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub run {
    return 1 if check_var('OPENQA_FROM_GIT', 1);
    diag('assuming to be in terminal');
    diag('initialize working copy of openSUSE tests distribution with correct user');
    assert_script_run('username=bernhard email=bernhard@susetest /usr/share/openqa/script/fetchneedles', 3600);
    save_screenshot;

    # 104 is the zypper exit code if a package cannot be found
    my $cmd = <<'EOM';
(
    for i in {1..7}
    do
        zypper --non-interactive install os-autoinst-distri-opensuse-deps && exit 0
        rc=$?
        (( $rc == 104 )) || break
    done
    exit $rc
)
EOM
    chomp $cmd;
    my $ret = assert_script_run(
        $cmd,
        timeout => 600,
    );
    type_string "clear\n";
    # prepare for next test
    type_string "logout\n";
    switch_to_x11;
}

1;

