use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

use OpenQA::Wheel::Launcher 'start_gui_program';

sub run {
    unless (get_required_var('VERSION') =~ /(tw|Tumbleweed)/) {
        record_soft_failure 'SKIPPED - module not ready for ' . get_required_var('VERSION');
        return;
    }
    prepare_firefox_autoconfig;
    switch_to_x11;
    ensure_unlocked_desktop();
    start_gui_program('firefox http://localhost', 60, valid => 1);
    #wait few minutes for ff to start and then fail the test
    assert_screen 'openqa-dashboard', 600;
}
1;
