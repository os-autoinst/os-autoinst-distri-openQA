use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub run {
    send_key 'ctrl-alt-f7';
    # wait_for_desktop;
    ensure_unlocked_desktop();
    x11_start_program("firefox http://localhost", 60, { valid => 1 } );
    # starting from git might take a bit longer to get and generated assets
    assert_screen 'openqa-dashboard', check_var('OPENQA_FROM_GIT',1) ? 180 : 60;
}
1;
