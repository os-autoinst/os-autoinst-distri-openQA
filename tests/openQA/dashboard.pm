use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

use OpenQA::Wheel::Launcher 'start_gui_program';

sub run {
    switch_to_root_console;
    prepare_firefox_autoconfig;
    switch_to_x11;
    ensure_unlocked_desktop();
    start_gui_program('firefox http://127.0.0.1', 60, valid => 1);
    #wait few minutes for ff to start and then fail the test
    assert_screen 'openqa-dashboard', 600;
}
1;
