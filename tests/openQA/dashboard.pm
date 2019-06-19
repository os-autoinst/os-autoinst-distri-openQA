use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub run {
    switch_to_x11;
    ensure_unlocked_desktop();
    x11_start_program("firefox http://localhost", 60, { valid => 1 } );
    # starting from git might take a bit longer to get and generated assets
    # workaround for poo#19798, basically doubles the timeout
    if ((check_screen 'openqa-dashboard', 180) == undef) {
        record_soft_failure 'ff took to long to start';
    }
    #wait few minutes for ff to start and then fail the test
    assert_screen 'openqa-dashboard', 360;
}
1;
